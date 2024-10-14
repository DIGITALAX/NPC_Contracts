import { Address, BigInt, ByteArray, Bytes } from "@graphprotocol/graph-ts";
import {
  NPCSpectate,
  NPCVote as NPCVoteEvent,
  PubVote as PubVoteEvent,
  WeeklyReset as WeeklyResetEvent,
} from "../generated/NPCSpectate/NPCSpectate";
import { NPCVote, PubVote, WeeklyReset } from "../generated/schema";

export function handleNPCVote(event: NPCVoteEvent): void {
  let entity = new NPCVote(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.npc = event.params.npc;

  entity.id = Bytes.fromByteArray(
    ByteArray.fromBigInt(BigInt.fromString(event.params.npc.toString()))
  );

  if (!entity.spectator) {
    entity.spectator = [];
  }

  (entity.spectator as Array<Bytes>).push(event.params.spectator);

  if (!entity.blockNumber) {
    entity.blockNumber = [];
  }

  (entity.blockNumber as Array<BigInt>).push(event.block.number);

  if (!entity.blockTimestamp) {
    entity.blockTimestamp = [];
  }

  (entity.blockTimestamp as Array<BigInt>).push(event.block.timestamp);

  if (!entity.transactionHash) {
    entity.transactionHash = [];
  }

  (entity.transactionHash as Array<Bytes>).push(event.transaction.hash);

  let datos = NPCSpectate.bind(
    Address.fromString("0x6B92Fb260e98dAEb1c4C613b16CC9D4bc5d6F184")
  );

  const freq = datos
    .getSpectatorNPCTotalLocalFrequency(
      event.params.spectator,
      event.params.npc
    )
    .minus(BigInt.fromI32(1));

  if (!entity.comment) {
    entity.comment = [];
  }

  (entity.comment as Array<String>).push(
    datos.getNPCVoteComment(event.params.spectator, event.params.npc, freq)
  );

  if (!entity.model) {
    entity.model = [];
  }

  (entity.model as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getNPCVoteModel(event.params.spectator, event.params.npc, freq)
        .toString()
    )
  );

  if (!entity.chatContext) {
    entity.chatContext = [];
  }

  (entity.chatContext as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getNPCVoteComment(event.params.spectator, event.params.npc, freq)
        .toString()
    )
  );

  if (!entity.spriteSheet) {
    entity.spriteSheet = [];
  }

  (entity.spriteSheet as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getNPCVoteSpriteSheet(event.params.spectator, event.params.npc, freq)
        .toString()
    )
  );

  if (!entity.lora) {
    entity.lora = [];
  }

  (entity.lora as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getNPCVoteLora(event.params.spectator, event.params.npc, freq)
        .toString()
    )
  );

  if (!entity.personality) {
    entity.personality = [];
  }

  (entity.personality as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getNPCVotePersonality(event.params.spectator, event.params.npc, freq)
        .toString()
    )
  );

  if (!entity.tokenizer) {
    entity.tokenizer = [];
  }

  (entity.tokenizer as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getNPCVoteTokenizer(event.params.spectator, event.params.npc, freq)
        .toString()
    )
  );

  if (!entity.training) {
    entity.training = [];
  }

  (entity.training as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getNPCVoteTraining(event.params.spectator, event.params.npc, freq)
        .toString()
    )
  );

  if (!entity.completedJobs) {
    entity.training = [];
  }

  (entity.completedJobs as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getNPCVoteCompletedJobs(event.params.spectator, event.params.npc, freq)
        .toString()
    )
  );

  if (!entity.scene) {
    entity.scene = [];
  }

  (entity.scene as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getNPCVoteScene(event.params.spectator, event.params.npc, freq)
        .toString()
    )
  );

  if (!entity.global) {
    entity.global = [];
  }

  (entity.global as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getNPCVoteGlobal(event.params.spectator, event.params.npc, freq)
        .toString()
    )
  );

  entity.save();

  entity.save();
}

export function handlePubVote(event: PubVoteEvent): void {
  let entity = new PubVote(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.id = Bytes.fromByteArray(
    ByteArray.fromBigInt(
      BigInt.fromString(
        event.params.profileId.toString() + event.params.pubId.toString()
      )
    )
  );

  if (!entity.spectator) {
    entity.spectator = [];
  }

  (entity.spectator as Array<Bytes>).push(event.params.spectator);

  if (!entity.profileId) {
    entity.profileId = [];
  }

  (entity.profileId as Array<BigInt>).push(event.params.profileId);

  if (!entity.pubId) {
    entity.pubId = [];
  }

  (entity.pubId as Array<BigInt>).push(event.params.pubId);

  if (!entity.blockNumber) {
    entity.blockNumber = [];
  }

  (entity.blockNumber as Array<BigInt>).push(event.block.number);

  if (!entity.blockTimestamp) {
    entity.blockTimestamp = [];
  }

  (entity.blockTimestamp as Array<BigInt>).push(event.block.timestamp);

  if (!entity.transactionHash) {
    entity.transactionHash = [];
  }

  (entity.transactionHash as Array<Bytes>).push(event.transaction.hash);

  let datos = NPCSpectate.bind(
    Address.fromString("0x6B92Fb260e98dAEb1c4C613b16CC9D4bc5d6F184")
  );

  const freq = datos
    .getSpectatorPubTotalLocalFrequency(
      event.params.spectator,
      event.params.profileId,
      event.params.pubId
    )
    .minus(BigInt.fromI32(1));

  if (!entity.comment) {
    entity.comment = [];
  }

  (entity.comment as Array<String>).push(
    datos.getPubVoteComment(
      event.params.spectator,
      event.params.profileId,
      event.params.pubId,
      freq
    )
  );

  if (!entity.npc) {
    entity.npc = [];
  }

  (entity.npc as Array<Bytes>).push(
    datos.getPubVoteNPC(
      event.params.spectator,
      event.params.profileId,
      event.params.pubId,
      freq
    )
  );

  if (!entity.model) {
    entity.model = [];
  }

  (entity.model as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getPubVoteModel(
          event.params.spectator,
          event.params.profileId,
          event.params.pubId,
          freq
        )
        .toString()
    )
  );

  if (!entity.chatContext) {
    entity.chatContext = [];
  }

  (entity.chatContext as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getPubVoteComment(
          event.params.spectator,
          event.params.profileId,
          event.params.pubId,
          freq
        )
        .toString()
    )
  );

  if (!entity.prompt) {
    entity.prompt = [];
  }

  (entity.prompt as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getPubVotePrompt(
          event.params.spectator,
          event.params.profileId,
          event.params.pubId,
          freq
        )
        .toString()
    )
  );

  if (!entity.style) {
    entity.style = [];
  }

  (entity.style as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getPubVoteStyle(
          event.params.spectator,
          event.params.profileId,
          event.params.pubId,
          freq
        )
        .toString()
    )
  );

  if (!entity.personality) {
    entity.personality = [];
  }

  (entity.personality as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getPubVotePersonality(
          event.params.spectator,
          event.params.profileId,
          event.params.pubId,
          freq
        )
        .toString()
    )
  );

  if (!entity.tokenizer) {
    entity.tokenizer = [];
  }

  (entity.tokenizer as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getPubVoteTokenizer(
          event.params.spectator,
          event.params.profileId,
          event.params.pubId,
          freq
        )
        .toString()
    )
  );

  if (!entity.media) {
    entity.media = [];
  }

  (entity.media as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getPubVoteMedia(
          event.params.spectator,
          event.params.profileId,
          event.params.pubId,
          freq
        )
        .toString()
    )
  );

  if (!entity.global) {
    entity.global = [];
  }

  (entity.global as Array<BigInt>).push(
    BigInt.fromString(
      datos
        .getPubVoteGlobal(
          event.params.spectator,
          event.params.profileId,
          event.params.pubId,
          freq
        )
        .toString()
    )
  );

  entity.save();
}

export function handleWeeklyReset(event: WeeklyResetEvent): void {
  let entity = new WeeklyReset(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.reseter = event.params.reseter;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}
