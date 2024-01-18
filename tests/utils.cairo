use core::result::ResultTrait;
use starknet::ContractAddress;
use snforge_std::{declare, ContractClassTrait};

mod Accounts{

    use starknet::ContractAddress;

    fn OWNER() -> ContractAddress{
        'owner'.try_into().unwrap()
    }

    fn BAD_ACTOR() -> ContractAddress{
        'bad_actor'.try_into().unwrap()
    }

    fn NEW_OWNER() -> ContractAddress{
        'new_owner'.try_into().unwrap()
    }
}


fn deploy_contract(counter: u32, address: ContractAddress) -> ContractAddress {
    let mut calldata = array![counter.into(), address.into()];
    let contract = declare('CounterContract');
    contract.deploy(@calldata).unwrap()
}