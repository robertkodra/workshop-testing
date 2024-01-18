use super::utils::{Accounts, deploy_contract};
use snforge_std::{declare, ContractClassTrait};
use snforge_std::{start_roll, stop_roll, CheatTarget};
use snforge_std::{start_warp, stop_warp};
use snforge_std::{start_mock_call, stop_mock_call};
use workshop::counter::{ICounterContractDispatcher, ICounterContractDispatcherTrait};
use openzeppelin::access::ownable::interface::{IOwnableDispatcher, IOwnableDispatcherTrait};


#[test]
fn test_mock_constructor_with_roll(){
    let contract = declare('CounterContract');

    let initial_counter : u32 = 42;
    let mut calldata = array![initial_counter.into(), Accounts::OWNER().into()];

    let contract_address = contract.precalculate_address(@calldata);

    start_roll(CheatTarget::One(contract_address), 777);

    let contract_address = contract.deploy(@calldata).unwrap();
    let dispatcher = ICounterContractDispatcher {contract_address};

    let blk_number = dispatcher.get_stored_block_number();
    assert(777 == blk_number, 'Block number mismatch');

    stop_roll(CheatTarget::One(contract_address));
}

#[test]
fn test_mock_constructor_with_warp() {
    let contract = declare('CounterContract');

    let initial_counter : u32 = 42;
    let mut calldata = array![initial_counter.into(), Accounts::OWNER().into()];
    let contract_address = contract.precalculate_address(@calldata);

    // block timestamp  
    start_warp(CheatTarget::One(contract_address), 1702903986);

    let contract_address = contract.deploy(@calldata).unwrap();
    let dispatcher = ICounterContractDispatcher { contract_address: contract_address };

    let blk_timestamp = dispatcher.get_stored_block_timestamp();

    assert(blk_timestamp == 1702903986, 'Block timestamp not equal!');

    stop_warp(CheatTarget::One(contract_address));
}

#[test]
fn test_mock_call() {
    let initial_counter = 0;
    let contract_address = deploy_contract(initial_counter, Accounts::OWNER());
    let dispatcher = ICounterContractDispatcher { contract_address: contract_address };

    start_mock_call(contract_address, 'get_stored_block_timestamp', 234);

    let blk_timestamp = dispatcher.get_stored_block_timestamp();

    assert(blk_timestamp == 234, 'Block timestamp not mocked');

    stop_mock_call(contract_address, 'get_stored_block_timestamp');

    let new_blk_timestmap = dispatcher.get_stored_block_timestamp();

    assert(new_blk_timestmap != 234, 'Block timestamp not equal');
}