use super::utils::{Accounts, deploy_contract};
use snforge_std::{declare, ContractClassTrait};
use snforge_std::{start_prank, stop_prank, CheatTarget};
use workshop::counter::{ICounterContractDispatcher, ICounterContractDispatcherTrait};
use openzeppelin::access::ownable::interface::{IOwnableDispatcher, IOwnableDispatcherTrait};


#[test]
fn test_increase_counter_as_owner(){
    let initial_counter : u32 = 42;
    
    let contract_address = deploy_contract(initial_counter, Accounts::OWNER());
    let dispatcher = ICounterContractDispatcher { contract_address };

    // change caller address
    start_prank(CheatTarget::One(contract_address), Accounts::OWNER());

    dispatcher.increase_counter();

    assert(initial_counter + 1 == dispatcher.get_counter(), 'Mismatch');

    stop_prank(CheatTarget::One(contract_address));
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn test_increase_counter_as_bad_actor(){
    let initial_counter : u32 = 42;
    
    let contract_address = deploy_contract(initial_counter, Accounts::OWNER());
    let dispatcher = ICounterContractDispatcher { contract_address };

    // change caller address
    start_prank(CheatTarget::One(contract_address), Accounts::BAD_ACTOR());

    dispatcher.increase_counter();

    assert(initial_counter + 1 == dispatcher.get_counter(), 'Mismatch');

    stop_prank(CheatTarget::One(contract_address));
}

#[test]
fn test_transfer_ownership_as_owner() {
    let initial_counter = 0;
    let contract_address = deploy_contract(initial_counter, Accounts::OWNER());
    let dispatcher = IOwnableDispatcher { contract_address };

    start_prank(CheatTarget::One(contract_address), Accounts::OWNER());
    dispatcher.transfer_ownership(Accounts::NEW_OWNER());
    let current_owner = dispatcher.owner();
    assert(current_owner == Accounts::NEW_OWNER(), 'Owner not changed');
    stop_prank(CheatTarget::One(contract_address));
}

#[test]
fn test_renounce_ownership_as_owner() {
    let initial_counter = 0;
    let contract_address = deploy_contract(initial_counter, Accounts::OWNER());
    let dispatcher = IOwnableDispatcher { contract_address };

    start_prank(CheatTarget::One(contract_address), Accounts::OWNER());
    dispatcher.renounce_ownership();
    let current_owner = dispatcher.owner();
    assert(current_owner == Zeroable::zero(), 'Owner not renounced');
    stop_prank(CheatTarget::One(contract_address));
}