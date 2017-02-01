// Methodology:
// Create all of the solution code first.
// Then break it. Search for TODOs

// 01 DOS with Block Gas Limit
// 02 DOS with (Unexpected) Throw
// 03 Don't assume contracts are created with zero balance
// 04 Beware division by zero
// 05 DoS with (Unexpected) Throw
// 06 Untrusted source of randomness
// 07 Logic error: halted jackpot withdrawal cannot resume
// 08 No players - withdrawAllFunds called before any players registered
// 09 Hijacking 1: withdrawFunds will go to an attacker
// 10 Reentry bug in withdrawFunds. Needs to be marked as untrusted
// 11 withdrawAllFunds was not been specified as private - anyone can set jackpot

pragma solidity ^0.4.4; // FIX 04: Upgrade solidity past 0.4 to fix div by 0

contract Example {

    address owner;

    struct Player {
        address addr;
        uint256 value;
        uint256 attemptsMade;
    }
    Player players[];

    uint256 nextWithdrawIndex; // FIX 01: Account for code halting
    boolean wasWithdrawingJackpot; // FIX 07: Save if it was jackpot withdrawal

    function Example() {
        // FIX 03 change to this.balance so that we account for initial deposit
        potBalance = this.balance;
        owner = msg.sender;
        wasWithdrawingJackpot = false;
    }

    function registerAndDeposit() payable {
        potBalance += msg.value;
        players.push(Player(msg.sender, msg.value, 0));
    }

    // Everyone is given a small chance to win the jackpot
    function potAttempt() payable {

        if (msg.value < 4) { // High rollers only
            potBalance += msg.value;
            throw;
        } else {
            potBalance += msg.value;
            players[msg.sender].attemptsMade += 1;
        }

        // FIX 06: Need to use a previous block, otherwise a miner can
        // manipulate whether or not this transaction is included in their
        // block or not.
        bytes32 lastblockhash = block.blockhash(block.number - 1);
        uint128 randomNumber = uint128(lastblockhash)
        if (randomNumber < 2) {
            // You've hit the jackpot! Share your public funds like a good
            // Berkeley liberal.

            // FIX 05: Remove the if check for potBalance otherwise we might have
            // a DoS error

            this.withdrawAllFunds(true);
        }
    }

    // FIX 10: Mark the withdrawal as untrusted for good practice
    function untrustedWithdrawFunds(uint256 playerIndex) public {
        // FIX 09: Use msg.sender so that you can't hijack the original caller
        // of a function to steal their money
        if (players[playerIndex].addr == msg.sender) {
            uint accountBalance = players[playerIndex].value;
            // FIX 09: Always send to the saved address in the contract
            players[playerIndex].value = 0; // FIX 10: Reorder to prevent reentry
            if (!(players[playerIndex].addr.deposit.value(accountBalance)())) {
                throw;
            }
        }
    }

    // FIX 11: Introduce a public function that forces the jackpot parameter to
    // be false
    function withdrawAllPublicFunds() {
        // Shout to my main man Nick Dirks
        this.withdrawAllFunds(false);
    }

    // FIX 11: Make withdrawAllFunds a private method
    function withdrawAllFunds(boolean wasJackpot) private {

        if (msg.sender != owner) {
            throw;
        }

        uint256 i = nextWithdrawIndex;

        // FIX 01: Added check for msg.gas so that we can properly save the index
        // in order to resume withdrawals in the next iteration.
        while (i < players.length && msg.gas > 200000) {
            uint128 shareValue;
            if (wasJackpot || wasWithdrawingJackpot) { // FIX 07: Check for jack
                // FIX 04: Add if-else check in case players.length is zero
                if (players.length > 0) {
                    shareValue = potBalance / players.length;
                } else {
                    shareValue = this.balance; // FIX 08: Case of no players
                }

            } else {
                shareValue = players[i].value;
            }

            // FIX 02: If check has been removed so that one throw won't halt
            // errors for everyone else
            players[i].addr.send(players[i].value);
            i++;
        }
        nextWithdrawIndex = i; // FIX 01: Account for code halting
        wasWithdrawingJackpot = false; // FIX 07: Withdraw issues
    }
}
