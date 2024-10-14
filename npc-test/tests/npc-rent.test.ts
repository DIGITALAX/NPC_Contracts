import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { BigInt, Address } from "@graphprotocol/graph-ts"
import { MissedRentDistributed } from "../generated/schema"
import { MissedRentDistributed as MissedRentDistributedEvent } from "../generated/NPCRent/NPCRent"
import { handleMissedRentDistributed } from "../src/npc-rent"
import { createMissedRentDistributedEvent } from "./npc-rent-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let amount = BigInt.fromI32(234)
    let newMissedRentDistributedEvent = createMissedRentDistributedEvent(amount)
    handleMissedRentDistributed(newMissedRentDistributedEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("MissedRentDistributed created and stored", () => {
    assert.entityCount("MissedRentDistributed", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "MissedRentDistributed",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "amount",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
