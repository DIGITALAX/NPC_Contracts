import {
  NPCVote as NPCVoteEvent,
  PubVote as PubVoteEvent,
  WeeklyReset as WeeklyResetEvent
} from "../generated/NPCSpectate/NPCSpectate"
import { NPCVote, PubVote, WeeklyReset } from "../generated/schema"

export function handleNPCVote(event: NPCVoteEvent): void {
  let entity = new NPCVote(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.spectator = event.params.spectator
  entity.npc = event.params.npc

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handlePubVote(event: PubVoteEvent): void {
  let entity = new PubVote(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.spectator = event.params.spectator
  entity.profileId = event.params.profileId
  entity.pubId = event.params.pubId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleWeeklyReset(event: WeeklyResetEvent): void {
  let entity = new WeeklyReset(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.reseter = event.params.reseter

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
