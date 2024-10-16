import {
  AdminAdded as AdminAddedEvent,
  AdminRemoved as AdminRemovedEvent,
  NPCAdded as NPCAddedEvent,
  NPCRemoved as NPCRemovedEvent,
} from "../generated/NPCAccessControls/NPCAccessControls"
import {
  AdminAdded,
  AdminRemoved,
  NPCAdded,
  NPCRemoved,
} from "../generated/schema"

export function handleAdminAdded(event: AdminAddedEvent): void {
  let entity = new AdminAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.admin = event.params.admin

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleAdminRemoved(event: AdminRemovedEvent): void {
  let entity = new AdminRemoved(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.admin = event.params.admin

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleNPCAdded(event: NPCAddedEvent): void {
  let entity = new NPCAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.npc = event.params.npc

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleNPCRemoved(event: NPCRemovedEvent): void {
  let entity = new NPCRemoved(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.npc = event.params.npc

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
