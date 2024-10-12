import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { NPCVote } from "../generated/schema"
import { NPCVote as NPCVoteEvent } from "../generated/NPCSpectate/NPCSpectate"
import { handleNPCVote } from "../src/npc-spectate"
import { createNPCVoteEvent } from "./npc-spectate-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let spectator = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let npc = Address.fromString("0x0000000000000000000000000000000000000001")
    let newNPCVoteEvent = createNPCVoteEvent(spectator, npc)
    handleNPCVote(newNPCVoteEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("NPCVote created and stored", () => {
    assert.entityCount("NPCVote", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "NPCVote",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "spectator",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "NPCVote",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "npc",
      "0x0000000000000000000000000000000000000001"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
