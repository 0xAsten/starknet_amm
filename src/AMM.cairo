use starknet::ContractAddress;

#[starknet::interface]
pub trait IStarknetAMM<TContractState> {
    fn add_liquidity(ref self: TContractState, token1_amount: u256, token2_amount: u256);
    fn get_amount_out(self: @TContractState, amount_in: u256, reserve_in: u256, reserve_out: u256) -> u256;
    fn swap(ref self: TContractState, token_address: ContractAddress, amount_in: u256);
}

#[starknet::interface]
pub trait IERC20<TState> {
    fn transfer(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
}


#[starknet::contract]
mod StarknetAMM {
    use starknet::{get_caller_address, ContractAddress, get_contract_address};

    use super::{IERC20Dispatcher, IERC20DispatcherTrait};

    #[storage]
    struct Storage {
        // token 1 amount
        x: u256,
        // token 2 amount
        y: u256,
        // constant
        k: u256,
        token1_address: ContractAddress,
        token2_address: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, _token1_address: ContractAddress, _token2_address: ContractAddress) {
        self.token1_address.write(_token1_address);
        self.token2_address.write(_token2_address);
    }

    #[abi(embed_v0)]
    impl StarknetAMM of super::IStarknetAMM<ContractState> {
        fn add_liquidity(ref self: ContractState, token1_amount: u256, token2_amount: u256) {
            assert(token1_amount != 0, 'Amount cannot be 0');
            assert(token2_amount != 0, 'Amount cannot be 0');

            let token1Address: ContractAddress = self.token1_address.read();
            IERC20Dispatcher {contract_address: token1Address}.transfer_from(
                get_caller_address(),
                get_contract_address(),
                token1_amount
            );

            let token2Address: ContractAddress = self.token2_address.read();
            IERC20Dispatcher {contract_address: token2Address}.transfer_from(
                get_caller_address(),
                get_contract_address(),
                token2_amount
            );

            self.x.write(self.x.read() + token1_amount);
            self.y.write(self.y.read() + token2_amount);
            self.k.write(self.x.read() * self.y.read());
        }

        fn get_amount_out(self: @ContractState, amount_in: u256, reserve_in: u256, reserve_out: u256) -> u256 {
            let denominator = reserve_in + amount_in;
            let k: u256 = self.k.read();
            reserve_out - k / denominator
        }

        fn swap(ref self: ContractState, token_address: ContractAddress, amount_in: u256) {
            assert(amount_in != 0, 'Amount cannot be 0');

            let token1Address: ContractAddress = self.token1_address.read();
            let token2Address: ContractAddress = self.token2_address.read();
            let token1_reserve: u256 = self.x.read();
            let token2_reserve: u256 = self.y.read();

            assert(token_address == token1Address || token_address == token2Address, 'Invalid token address');
            assert(token1_reserve != 0 && token2_reserve != 0, 'Invalid reserves');

            let amount_out = if token_address == token1Address {
                self.get_amount_out(amount_in, token1_reserve, token2_reserve)
            } else {
                self.get_amount_out(amount_in, token2_reserve, token1_reserve)
            };

            IERC20Dispatcher {contract_address: token_address}.transfer_from(
                get_caller_address(),
                get_contract_address(),
                amount_in
            );

            if token_address == token1Address {
                IERC20Dispatcher {contract_address: token2Address}.transfer(
                    get_contract_address(),
                    amount_out
                );
                self.x.write(token1_reserve + amount_in);
                self.y.write(token2_reserve - amount_out);
            } else {
                IERC20Dispatcher {contract_address: token1Address}.transfer(
                    get_contract_address(),
                    amount_out
                );
                self.x.write(token1_reserve - amount_out);
                self.y.write(token2_reserve + amount_in);
            }
        }
       
    }
}
