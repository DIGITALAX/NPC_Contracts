import { newMockEvent } from "matchstick-as"
import { ethereum, BigInt, Address } from "@graphprotocol/graph-ts"
import {
  MissedRentDistributed,
  NPCWeightsCalculated,
  RentMissed,
  RentPaid,
  SpectatorClaimed,
  SpectatorClaimedAll,
  SpectatorWeightsCalculated
} from "../generated/NPCRent/NPCRent"

export function createMissedRentDistributedEvent(
  amount: BigInt
): MissedRentDistributed {
  let missedRentDistributedEvent = changetype<MissedRentDistributed>(
    newMockEvent()
  )

  missedRentDistributedEvent.parameters = new Array()

  missedRentDistributedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return missedRentDistributedEvent
}

export function createNPCWeightsCalculatedEvent(
  npc: Address,
  globalWeight: BigInt
): NPCWeightsCalculated {
  let npcWeightsCalculatedEvent = changetype<NPCWeightsCalculated>(
    newMockEvent()
  )

  npcWeightsCalculatedEvent.parameters = new Array()

  npcWeightsCalculatedEvent.parameters.push(
    new ethereum.EventParam("npc", ethereum.Value.fromAddress(npc))
  )
  npcWeightsCalculatedEvent.parameters.push(
    new ethereum.EventParam(
      "globalWeight",
      ethereum.Value.fromUnsignedBigInt(globalWeight)
    )
  )

  return npcWeightsCalculatedEvent
}

export function createRentMissedEvent(
  npc: Address,
  auAmountPaid: BigInt
): RentMissed {
  let rentMissedEvent = changetype<RentMissed>(newMockEvent())

  rentMissedEvent.parameters = new Array()

  rentMissedEvent.parameters.push(
    new ethereum.EventParam("npc", ethereum.Value.fromAddress(npc))
  )
  rentMissedEvent.parameters.push(
    new ethereum.EventParam(
      "auAmountPaid",
      ethereum.Value.fromUnsignedBigInt(auAmountPaid)
    )
  )

  return rentMissedEvent
}

export function createRentPaidEvent(
  npc: Address,
  auAmountClaimed: BigInt,
  auAmountPaid: BigInt
): RentPaid {
  let rentPaidEvent = changetype<RentPaid>(newMockEvent())

  rentPaidEvent.parameters = new Array()

  rentPaidEvent.parameters.push(
    new ethereum.EventParam("npc", ethereum.Value.fromAddress(npc))
  )
  rentPaidEvent.parameters.push(
    new ethereum.EventParam(
      "auAmountClaimed",
      ethereum.Value.fromUnsignedBigInt(auAmountClaimed)
    )
  )
  rentPaidEvent.parameters.push(
    new ethereum.EventParam(
      "auAmountPaid",
      ethereum.Value.fromUnsignedBigInt(auAmountPaid)
    )
  )

  return rentPaidEvent
}

export function createSpectatorClaimedEvent(
  spectator: Address,
  auAmountClaimed: BigInt
): SpectatorClaimed {
  let spectatorClaimedEvent = changetype<SpectatorClaimed>(newMockEvent())

  spectatorClaimedEvent.parameters = new Array()

  spectatorClaimedEvent.parameters.push(
    new ethereum.EventParam("spectator", ethereum.Value.fromAddress(spectator))
  )
  spectatorClaimedEvent.parameters.push(
    new ethereum.EventParam(
      "auAmountClaimed",
      ethereum.Value.fromUnsignedBigInt(auAmountClaimed)
    )
  )

  return spectatorClaimedEvent
}

export function createSpectatorClaimedAllEvent(
  spectator: Address,
  auAmountClaimed: BigInt
): SpectatorClaimedAll {
  let spectatorClaimedAllEvent = changetype<SpectatorClaimedAll>(newMockEvent())

  spectatorClaimedAllEvent.parameters = new Array()

  spectatorClaimedAllEvent.parameters.push(
    new ethereum.EventParam("spectator", ethereum.Value.fromAddress(spectator))
  )
  spectatorClaimedAllEvent.parameters.push(
    new ethereum.EventParam(
      "auAmountClaimed",
      ethereum.Value.fromUnsignedBigInt(auAmountClaimed)
    )
  )

  return spectatorClaimedAllEvent
}

export function createSpectatorWeightsCalculatedEvent(
  npc: Address,
  globalWeight: BigInt,
  globalWeightNormalized: BigInt
): SpectatorWeightsCalculated {
  let spectatorWeightsCalculatedEvent = changetype<SpectatorWeightsCalculated>(
    newMockEvent()
  )

  spectatorWeightsCalculatedEvent.parameters = new Array()

  spectatorWeightsCalculatedEvent.parameters.push(
    new ethereum.EventParam("npc", ethereum.Value.fromAddress(npc))
  )
  spectatorWeightsCalculatedEvent.parameters.push(
    new ethereum.EventParam(
      "globalWeight",
      ethereum.Value.fromUnsignedBigInt(globalWeight)
    )
  )
  spectatorWeightsCalculatedEvent.parameters.push(
    new ethereum.EventParam(
      "globalWeightNormalized",
      ethereum.Value.fromUnsignedBigInt(globalWeightNormalized)
    )
  )

  return spectatorWeightsCalculatedEvent
}
