import { newMockEvent } from "matchstick-as"
import { ethereum, Address } from "@graphprotocol/graph-ts"
import {
  AdminAdded,
  AdminRemoved,
  NPCAdded,
  NPCRemoved
} from "../generated/NPCAccessControls/NPCAccessControls"

export function createAdminAddedEvent(admin: Address): AdminAdded {
  let adminAddedEvent = changetype<AdminAdded>(newMockEvent())

  adminAddedEvent.parameters = new Array()

  adminAddedEvent.parameters.push(
    new ethereum.EventParam("admin", ethereum.Value.fromAddress(admin))
  )

  return adminAddedEvent
}

export function createAdminRemovedEvent(admin: Address): AdminRemoved {
  let adminRemovedEvent = changetype<AdminRemoved>(newMockEvent())

  adminRemovedEvent.parameters = new Array()

  adminRemovedEvent.parameters.push(
    new ethereum.EventParam("admin", ethereum.Value.fromAddress(admin))
  )

  return adminRemovedEvent
}

export function createNPCAddedEvent(npc: Address): NPCAdded {
  let npcAddedEvent = changetype<NPCAdded>(newMockEvent())

  npcAddedEvent.parameters = new Array()

  npcAddedEvent.parameters.push(
    new ethereum.EventParam("npc", ethereum.Value.fromAddress(npc))
  )

  return npcAddedEvent
}

export function createNPCRemovedEvent(npc: Address): NPCRemoved {
  let npcRemovedEvent = changetype<NPCRemoved>(newMockEvent())

  npcRemovedEvent.parameters = new Array()

  npcRemovedEvent.parameters.push(
    new ethereum.EventParam("npc", ethereum.Value.fromAddress(npc))
  )

  return npcRemovedEvent
}
