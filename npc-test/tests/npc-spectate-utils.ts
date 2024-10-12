import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  NPCVote,
  PubVote,
  WeeklyReset
} from "../generated/NPCSpectate/NPCSpectate"

export function createNPCVoteEvent(spectator: Address, npc: Address): NPCVote {
  let npcVoteEvent = changetype<NPCVote>(newMockEvent())

  npcVoteEvent.parameters = new Array()

  npcVoteEvent.parameters.push(
    new ethereum.EventParam("spectator", ethereum.Value.fromAddress(spectator))
  )
  npcVoteEvent.parameters.push(
    new ethereum.EventParam("npc", ethereum.Value.fromAddress(npc))
  )

  return npcVoteEvent
}

export function createPubVoteEvent(
  spectator: Address,
  profileId: BigInt,
  pubId: BigInt
): PubVote {
  let pubVoteEvent = changetype<PubVote>(newMockEvent())

  pubVoteEvent.parameters = new Array()

  pubVoteEvent.parameters.push(
    new ethereum.EventParam("spectator", ethereum.Value.fromAddress(spectator))
  )
  pubVoteEvent.parameters.push(
    new ethereum.EventParam(
      "profileId",
      ethereum.Value.fromUnsignedBigInt(profileId)
    )
  )
  pubVoteEvent.parameters.push(
    new ethereum.EventParam("pubId", ethereum.Value.fromUnsignedBigInt(pubId))
  )

  return pubVoteEvent
}

export function createWeeklyResetEvent(reseter: Address): WeeklyReset {
  let weeklyResetEvent = changetype<WeeklyReset>(newMockEvent())

  weeklyResetEvent.parameters = new Array()

  weeklyResetEvent.parameters.push(
    new ethereum.EventParam("reseter", ethereum.Value.fromAddress(reseter))
  )

  return weeklyResetEvent
}
