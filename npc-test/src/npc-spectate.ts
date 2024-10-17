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
    ByteArray.fromHexString(event.params.npc.toHexString())
  );

  let entity = NPCVote.load(entityId);

  if (!entity) {
    entity = new NPCVote(entityId);
  }
  entity.npc = event.params.npc;

  let spectator = entity.spectator || new Array<Bytes>();
  (spectator as Array<Bytes>).push(event.params.spectator);
  entity.spectator = spectator;

  let blockNumber = entity.blockNumber || new Array<BigInt>();
  (blockNumber as Array<BigInt>).push(event.block.number);
  entity.blockNumber = blockNumber;

  let blockTimestamp = entity.blockTimestamp || new Array<BigInt>();
  (blockTimestamp as Array<BigInt>).push(event.block.timestamp);
  entity.blockTimestamp = blockTimestamp;

  let transactionHash = entity.transactionHash || new Array<Bytes>();
  (transactionHash as Array<Bytes>).push(event.transaction.hash);
  entity.transactionHash = transactionHash;

  let datos = NPCSpectate.bind(
    Address.fromString("0x6B92Fb260e98dAEb1c4C613b16CC9D4bc5d6F184")
  );

  const freq = datos
    .getSpectatorNPCTotalLocalFrequency(
      event.params.spectator,
      event.params.npc
    )
    .minus(BigInt.fromI32(1));

  let comment = entity.comment || new Array<string>();
  (comment as Array<string>).push(
    datos.getNPCVoteComment(event.params.spectator, event.params.npc, freq)
  );
  entity.comment = comment;

  let model = entity.model || new Array<BigInt>();
  (model as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteModel(event.params.spectator, event.params.npc, freq)
    )
  );
  entity.model = model;

  let chatContext = entity.chatContext || new Array<BigInt>();
  (chatContext as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteChatContext(
        event.params.spectator,
        event.params.npc,
        freq
      )
    )
  );
  entity.chatContext = chatContext;

  let appearance = entity.appearance || new Array<BigInt>();
  (appearance as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteAppearance(event.params.spectator, event.params.npc, freq)
    )
  );
  entity.appearance = appearance;

  let spriteSheet = entity.spriteSheet || new Array<BigInt>();
  (spriteSheet as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteSpriteSheet(
        event.params.spectator,
        event.params.npc,
        freq
      )
    )
  );
  entity.spriteSheet = spriteSheet;

  let lora = entity.lora || new Array<BigInt>();
  (lora as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteLora(event.params.spectator, event.params.npc, freq)
    )
  );
  entity.lora = lora;

  let personality = entity.personality || new Array<BigInt>();
  (personality as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVotePersonality(
        event.params.spectator,
        event.params.npc,
        freq
      )
    )
  );
  entity.personality = personality;

  let tokenizer = entity.tokenizer || new Array<BigInt>();
  (tokenizer as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteTokenizer(event.params.spectator, event.params.npc, freq)
    )
  );
  entity.tokenizer = tokenizer;

  let training = entity.training || new Array<BigInt>();
  (training as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteTraining(event.params.spectator, event.params.npc, freq)
    )
  );
  entity.training = training;

  let completedJobs = entity.completedJobs || new Array<BigInt>();
  (completedJobs as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteCompletedJobs(
        event.params.spectator,
        event.params.npc,
        freq
      )
    )
  );
  entity.completedJobs = completedJobs;

  let scene = entity.scene || new Array<BigInt>();
  (scene as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteScene(event.params.spectator, event.params.npc, freq)
    )
  );
  entity.scene = scene;

  let global = entity.global || new Array<BigInt>();
  (global as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getNPCVoteGlobal(event.params.spectator, event.params.npc, freq)
    )
  );
  entity.global = global;

  entity.save();
}

export function handlePubVote(event: PubVoteEvent): void {
  let entityId = Bytes.fromByteArray(
    ByteArray.fromBigInt(event.params.profileId).concat(
      ByteArray.fromBigInt(event.params.pubId)
    )
  );

  let entity = PubVote.load(entityId);
  if (!entity) {
    entity = new PubVote(entityId);

    entity.profileId = event.params.profileId;

    entity.pubId = event.params.pubId;
  }

  let spectators = entity.spectator || new Array<Bytes>();
  (spectators as Array<Bytes>).push(event.params.spectator);
  entity.spectator = spectators;

  let blockNumber = entity.blockNumber || new Array<BigInt>();
  (blockNumber as Array<BigInt>).push(event.block.number);
  entity.blockNumber = blockNumber;

  let blockTimestamp = entity.blockTimestamp || new Array<BigInt>();
  (blockTimestamp as Array<BigInt>).push(event.block.timestamp);
  entity.blockTimestamp = blockTimestamp;

  let transactionHash = entity.transactionHash || new Array<Bytes>();
  (transactionHash as Array<Bytes>).push(event.transaction.hash);
  entity.transactionHash = transactionHash;

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

  let comment = entity.comment || new Array<string>();
  (comment as Array<string>).push(
    datos.getPubVoteComment(
      event.params.spectator,
      event.params.profileId,
      event.params.pubId,
      freq
    )
  );
  entity.comment = comment;

  let npc = entity.npc || new Array<Bytes>();
  (npc as Array<Bytes>).push(
    datos.getPubVoteNPC(
      event.params.spectator,
      event.params.profileId,
      event.params.pubId,
      freq
    )
  );
  entity.npc = npc;

  let model = entity.model || new Array<BigInt>();
  (model as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVoteModel(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );
  entity.model = model;

  let chatContext = entity.chatContext || new Array<BigInt>();
  (chatContext as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVoteChatContext(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );
  entity.chatContext = chatContext;

  let prompt = entity.prompt || new Array<BigInt>();
  (prompt as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVotePrompt(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );
  entity.prompt = prompt;

  let style = entity.style || new Array<BigInt>();
  (style as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVoteStyle(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );
  entity.style = style;

  let personality = entity.personality || new Array<BigInt>();
  (personality as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVotePersonality(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );
  entity.personality = personality;

  let tokenizer = entity.tokenizer || new Array<BigInt>();
  (tokenizer as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVoteTokenizer(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );
  entity.tokenizer = tokenizer;

  let media = entity.media || new Array<BigInt>();
  (media as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVoteMedia(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );
  entity.media = media;

  let global = entity.global || new Array<BigInt>();
  (global as Array<BigInt>).push(
    BigInt.fromI32(
      datos.getPubVoteGlobal(
        event.params.spectator,
        event.params.profileId,
        event.params.pubId,
        freq
      )
    )
  );
  entity.global = global;

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
