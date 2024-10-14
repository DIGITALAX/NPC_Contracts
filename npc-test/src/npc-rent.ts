import { Address, BigInt, ByteArray, Bytes } from "@graphprotocol/graph-ts";
import {
  MissedRentDistributed as MissedRentDistributedEvent,
  NPCWeightsCalculated as NPCWeightsCalculatedEvent,
  RentMissed as RentMissedEvent,
  RentPaid as RentPaidEvent,
  SpectatorClaimed as SpectatorClaimedEvent,
  SpectatorClaimedAll as SpectatorClaimedAllEvent,
  SpectatorWeightsCalculated as SpectatorWeightsCalculatedEvent,
  NPCRent,
} from "../generated/NPCRent/NPCRent";
import {
  LeaderboardNPC,
  LeaderboardSpectator,
  MissedRentDistributed,
  NPCInfo,
  NPCWeightsCalculated,
  RentMissed,
  RentPaid,
  RentPaidNPC,
  SpectatorClaimed,
  SpectatorClaimedAll,
  SpectatorInfo,
  SpectatorWeightsCalculated,
} from "../generated/schema";
import { NPCSpectate } from "../generated/NPCSpectate/NPCSpectate";

export function handleMissedRentDistributed(
  event: MissedRentDistributedEvent
): void {
  let entity = new MissedRentDistributed(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.amount = event.params.amount;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleNPCWeightsCalculated(
  event: NPCWeightsCalculatedEvent
): void {
  let entity = new NPCWeightsCalculated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.npc = event.params.npc;
  entity.globalWeight = event.params.globalWeight;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let spectate = NPCSpectate.bind(
    Address.fromString("0x6B92Fb260e98dAEb1c4C613b16CC9D4bc5d6F184")
  );

  let datos = NPCRent.bind(
    Address.fromString("0x7fb6f7EF8dfFb0bB8d82b64E6b90BcC5162621F6")
  );

  const npcs = spectate.getWeeklyNPCs();

  if (npcs) {
    for (let i = 0; i < npcs.length; i++) {
      let npcEntity = LeaderboardNPC.load(
        Bytes.fromByteArray(
          ByteArray.fromBigInt(BigInt.fromString(npcs[i].toString()))
        )
      );

      if (!npcEntity) {
        npcEntity = new LeaderboardNPC(
          Bytes.fromByteArray(
            ByteArray.fromBigInt(BigInt.fromString(npcs[i].toString()))
          )
        );

        npcEntity.npc = npcs[i];
      }

      npcEntity.totalScore = datos.getNPCCurrentWeightedScoreWeekly(npcs[i]);
      npcEntity.weeklyScore = datos.getNPCCurrentWeightedScoreWeekly(npcs[i]);

      npcEntity.save();
    }
  }

  entity.save();
}

export function handleRentMissed(event: RentMissedEvent): void {
  let entity = new RentMissed(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );

  let npcEntity = NPCInfo.load(
    Bytes.fromByteArray(
      ByteArray.fromBigInt(BigInt.fromString(event.params.npc.toString()))
    )
  );

  if (!npcEntity) {
    npcEntity = new NPCInfo(
      Bytes.fromByteArray(
        ByteArray.fromBigInt(BigInt.fromString(event.params.npc.toString()))
      )
    );

    npcEntity.npc = event.params.npc;
  }

  npcEntity.rentMissedTotal = event.params.auAmountPaid;

  npcEntity.save();

  entity.npc = event.params.npc;
  entity.auAmountPaid = event.params.auAmountPaid;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleRentPaid(event: RentPaidEvent): void {
  let entity = new RentPaid(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.npc = event.params.npc;
  entity.auAmountClaimed = event.params.auAmountClaimed;
  entity.auAmountPaid = event.params.auAmountPaid;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let npcRent = new RentPaidNPC(
    Bytes.fromByteArray(
      ByteArray.fromBigInt(BigInt.fromString(event.params.npc.toString()))
    )
  );

  if (!npcRent) {
    npcRent = new RentPaidNPC(
      Bytes.fromByteArray(
        ByteArray.fromBigInt(BigInt.fromString(event.params.npc.toString()))
      )
    );
    npcRent.npc = event.params.npc;
  }

  if (!npcRent.blockNumber) {
    npcRent.blockNumber = [];
  }

  (npcRent.blockNumber as Array<BigInt>).push(event.block.timestamp);
  if (!npcRent.transactionHash) {
    npcRent.transactionHash = [];
  }

  (npcRent.transactionHash as Array<Bytes>).push(event.transaction.hash);
  if (!npcRent.amount) {
    npcRent.amount = [];
  }

  (npcRent.amount as Array<BigInt>).push(event.params.auAmountPaid);

  npcRent.save();

  let npcEntity = NPCInfo.load(
    Bytes.fromByteArray(
      ByteArray.fromBigInt(BigInt.fromString(event.params.npc.toString()))
    )
  );

  if (!npcEntity) {
    npcEntity = new NPCInfo(
      Bytes.fromByteArray(
        ByteArray.fromBigInt(BigInt.fromString(event.params.npc.toString()))
      )
    );
    npcEntity.npc = event.params.npc;
  }

  let datos = NPCRent.bind(
    Address.fromString("0x7fb6f7EF8dfFb0bB8d82b64E6b90BcC5162621F6")
  );

  npcEntity.activeJobs = BigInt.fromI32(0);
  npcEntity.activeWeeks = datos.getNPCActiveWeeks(event.params.npc);

  let auEarnedTotal = BigInt.fromI32(0);
  let auPaidTotal = BigInt.fromI32(0);
  for (let i = 0; i < npcEntity.activeWeeks.toI32(); i++) {
    auEarnedTotal.plus(
      datos.getNPCAuClaimedByWeek(event.params.npc, BigInt.fromI32(i))
    );
    auPaidTotal.plus(
      datos.getNPCAuRentByWeek(event.params.npc, BigInt.fromI32(i))
    );
  }

  npcEntity.auEarnedTotal = auEarnedTotal;
  npcEntity.auPaidTotal = auPaidTotal;
  npcEntity.currentWeeklyScore = datos.getNPCCurrentWeightedScoreTotal(
    event.params.npc
  );
  npcEntity.currentGlobalScore = datos.getNPCCurrentWeightedScoreWeekly(
    event.params.npc
  );

  let spectate = NPCSpectate.bind(
    Address.fromString("0x6B92Fb260e98dAEb1c4C613b16CC9D4bc5d6F184")
  );
  const npcs = spectate.getWeeklyNPCs();
  let allGlobalScore = BigInt.fromI32(0);

  if (npcs) {
    for (let i = 0; i < npcs.length; i++) {
      allGlobalScore.plus(datos.getNPCCurrentWeightedScoreTotal(npcs[i]));
    }
  }

  npcEntity.allGlobalScore = allGlobalScore;

  npcEntity.save();

  entity.save();
}

export function handleSpectatorClaimed(event: SpectatorClaimedEvent): void {
  let entity = new SpectatorClaimed(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.spectator = event.params.spectator;
  entity.auAmountClaimed = event.params.auAmountClaimed;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleSpectatorClaimedAll(
  event: SpectatorClaimedAllEvent
): void {
  let entity = new SpectatorClaimedAll(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.spectator = event.params.spectator;
  entity.auAmountClaimed = event.params.auAmountClaimed;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let spectatorEntity = SpectatorInfo.load(
    Bytes.fromByteArray(
      ByteArray.fromBigInt(BigInt.fromString(event.params.spectator.toString()))
    )
  );

  if (!spectatorEntity) {
    spectatorEntity = new SpectatorInfo(
      Bytes.fromByteArray(
        ByteArray.fromBigInt(
          BigInt.fromString(event.params.spectator.toString())
        )
      )
    );

    spectatorEntity.spectator = event.params.spectator;
  }

  let datos = NPCRent.bind(
    Address.fromString("0x7fb6f7EF8dfFb0bB8d82b64E6b90BcC5162621F6")
  );

  spectatorEntity.weeklyPortion = datos.getSpectatorPortion(
    Address.fromBytes(spectatorEntity.spectator),
    datos.weekCounter()
  );
  spectatorEntity.auClaimedTotal = datos.getSpectatorAUClaimed(
    Address.fromBytes(spectatorEntity.spectator)
  );
  spectatorEntity.auUnclaimedTotal = datos.getSpectatorAUUnclaimed(
    Address.fromBytes(spectatorEntity.spectator)
  );
  spectatorEntity.auEarnedTotal = datos.getSpectatorAUEarned(
    Address.fromBytes(spectatorEntity.spectator)
  );

  spectatorEntity.weekWeight = datos.getSpectatorCurrentWeekWeight(
    Address.fromBytes(spectatorEntity.spectator)
  );
  spectatorEntity.save();

  entity.save();
}

export function handleSpectatorWeightsCalculated(
  event: SpectatorWeightsCalculatedEvent
): void {
  let entity = new SpectatorWeightsCalculated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.npc = event.params.npc;
  entity.globalWeight = event.params.globalWeight;
  entity.globalWeightNormalized = event.params.globalWeightNormalized;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let spectate = NPCSpectate.bind(
    Address.fromString("0x6B92Fb260e98dAEb1c4C613b16CC9D4bc5d6F184")
  );

  let datos = NPCRent.bind(
    Address.fromString("0x7fb6f7EF8dfFb0bB8d82b64E6b90BcC5162621F6")
  );

  const spectators = spectate.getWeeklySpectators();
  const semana = datos.weekCounter();

  if (spectators) {
    for (let i = 0; i < spectators.length; i++) {
      let spectatorEntity = LeaderboardSpectator.load(
        Bytes.fromByteArray(
          ByteArray.fromBigInt(BigInt.fromString(spectators[i].toString()))
        )
      );

      if (!spectatorEntity) {
        spectatorEntity = new LeaderboardSpectator(
          Bytes.fromByteArray(
            ByteArray.fromBigInt(BigInt.fromString(spectators[i].toString()))
          )
        );

        spectatorEntity.spectator = spectators[i];
      }
      let totalScore = BigInt.fromI32(0);
      for (let j = 0; j < semana.toI32(); j++) {
        totalScore.plus(
          datos.getSpectatorWeightByWeek(spectators[i], BigInt.fromI32(j))
        );
      }

      spectatorEntity.totalScore = totalScore;
      spectatorEntity.weeklyScore = datos.getSpectatorCurrentWeekWeight(
        spectators[i]
      );
      spectatorEntity.save();
    }
  }

  entity.save();
}
