use starknet::ContractAddress;

#[starknet::interface]
trait ICounterContract<TContractState> {
    fn get_counter(self: @TContractState) -> u32;
    fn increase_counter(ref self: TContractState);
    fn get_stored_block_number(self: @TContractState) -> u64;
    fn get_stored_block_timestamp(self: @TContractState) -> u64;
    fn sum(self: @TContractState, a: felt252, b: felt252) -> felt252;
}


#[starknet::contract]
mod CounterContract {
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::{ContractAddress, get_caller_address};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        counter: u32,
        block_number: u64,
        block_timestamp: u64,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnableEvent: OwnableComponent::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_counter: u32, initial_owner: ContractAddress) {
        self.counter.write(initial_counter);
        self.ownable.initializer(initial_owner);

        self.block_number.write(starknet::get_block_info().unbox().block_number);
        self.block_timestamp.write(starknet::get_block_info().unbox().block_timestamp);
    }

    #[abi(embed_v0)]
    impl CounterContract of super::ICounterContract<ContractState> {
        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }

        fn increase_counter(ref self: ContractState) {
            self.ownable.assert_only_owner();
            let current_counter = self.counter.read();
            self.counter.write(current_counter + 1);
        }

        fn get_stored_block_number(self: @ContractState) -> u64 {
            self.block_number.read()
        }

        fn get_stored_block_timestamp(self: @ContractState) -> u64 {
            self.block_timestamp.read()
        }

        fn sum(self: @ContractState, a: felt252, b: felt252) -> felt252 {
            a + b
        }
    }
}
