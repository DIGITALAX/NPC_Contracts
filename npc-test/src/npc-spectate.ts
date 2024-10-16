import { Address, BigInt, ByteArray, Bytes } from "@graphprotocol/graph-ts";
import {
  NPCSpectate,
  NPCVote as NPCVoteEvent,
  PubVote as PubVoteEvent,
  WeeklyReset as WeeklyResetEvent,
} from "../generated/NPCSpectate/NPCSpectate";
import { NPCVote, PubVote, WeeklyReset } from "../generated/schema";

export function handleNPCVote(event: NPCVoteEvent): void {
  let entityId = Bytes.fromByteArray(
    ByteArray.fromBigInt(BigInt.fromString(event.params.npc.toString()))
  );

  let entity = NPCVote.load(entityId);

  if (!entity) {
    entity = new NPCVote(entityId);
  }
  entity.npc = event.params.npc;

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
    BigInt.fromI32(
      datos.getNPCVoteModel(event.params.spectator, event.params.npc, freq)
    )
  );

  if (!entity.chatContext) {
    entity.chatContext = [];
  }

  (entity.chatContext as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteChatContext(
        event.params.spectator,
        event.params.npc,
        freq
      )
    )
  );

  if (!entity.spriteSheet) {
    entity.spriteSheet = [];
  }

  (entity.spriteSheet as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteSpriteSheet(
        event.params.spectator,
        event.params.npc,
        freq
      )
    )
  );

  if (!entity.lora) {
    entity.lora = [];
  }

  (entity.lora as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteLora(event.params.spectator, event.params.npc, freq)
    )
  );

  if (!entity.personality) {
    entity.personality = [];
  }

  (entity.personality as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVotePersonality(
        event.params.spectator,
        event.params.npc,
        freq
      )
    )
  );

  if (!entity.tokenizer) {
    entity.tokenizer = [];
  }

  (entity.tokenizer as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteTokenizer(event.params.spectator, event.params.npc, freq)
    )
  );

  if (!entity.training) {
    entity.training = [];
  }

  (entity.training as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteTraining(event.params.spectator, event.params.npc, freq)
    )
  );

  if (!entity.completedJobs) {
    entity.training = [];
  }

  (entity.completedJobs as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteCompletedJobs(
        event.params.spectator,
        event.params.npc,
        freq
      )
    )
  );

  if (!entity.scene) {
    entity.scene = [];
  }

  (entity.scene as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteScene(event.params.spectator, event.params.npc, freq)
    )
  );

  if (!entity.global) {
    entity.global = [];
  }

  (entity.global as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteGlobal(event.params.spectator, event.params.npc, freq)
    )
  );

  entity.save();

  entity.save();
}

export function handlePubVote(event: PubVoteEvent): void {
  let entityId = Bytes.fromByteArray(
    ByteArray.fromBigInt(
      BigInt.fromString(
        event.params.profileId.toString() + event.params.pubId.toString()
      )
    )
  );

  let entity = PubVote.load(entityId);
  if (!entity) {
    entity = new PubVote(entityId);
  }

  if (!entity.spectator) {
    entity.spectator = [];
  }

  (entity.spectator as Array<Bytes>).push(event.params.spectator);

  entity.profileId = event.params.profileId;

  entity.pubId = event.params.pubId;

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
    BigInt.fromI32(
      datos.getPubVoteModel(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );

  if (!entity.chatContext) {
    entity.chatContext = [];
  }

  (entity.chatContext as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVoteChatContext(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );

  if (!entity.prompt) {
    entity.prompt = [];
  }

  (entity.prompt as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVotePrompt(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );

  if (!entity.style) {
    entity.style = [];
  }

  (entity.style as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVoteStyle(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );

  if (!entity.personality) {
    entity.personality = [];
  }

  (entity.personality as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVotePersonality(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );

  if (!entity.tokenizer) {
    entity.tokenizer = [];
  }

  (entity.tokenizer as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVoteTokenizer(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );

  if (!entity.media) {
    entity.media = [];
  }

  (entity.media as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVoteMedia(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );

  if (!entity.global) {
    entity.global = [];
  }

  (entity.global as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVoteGlobal(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
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
