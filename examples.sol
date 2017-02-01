pragma solidity ^0.3.9;

contract Example {

    address owner;

    struct Player {
        address addr;
        uint256 value;
        uint256 attemptsMade;
    }
    Player players[];

    uint256 potBalance;

    function Example() {
        potBalance = 0;
        owner = msg.sender;
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

        bytes32 lastblockhash = block.blockhash(block.number);
        uint128 randomNumber = uint128(lastblockhash)
        if (randomNumber < 2) {
            // You've hit the jackpot! Share your public funds like a good
            // Berkeley liberal.

            // Ensure that we are distributing the correct amount of money.
            // Abort otherwise.
            if (this.balance != potBalance) {
                throw
            }

            this.withdrawAllFunds(true);
        }
    }

    function withdrawFunds(uint256 playerIndex) public {
        if (players[playerIndex].addr == msg.origin) {
            uint accountBalance = players[playerIndex].value;
            // Call the account owner's deposit function to send along a value
            // of accountBalance
            if (!(msg.sender.deposit.value(accountBalance)())) { throw; }
            players[playerIndex].value = 0;
        }
    }

    function withdrawAllFunds(boolean wasJackpot) {

        if (msg.sender != owner) {
            throw;
        }

        while (i < players.length) {
            uint128 shareValue;
            if (wasJackpot) {
                shareValue = potBalance / players.length;
            } else {
                shareValue = players[i].value;
            }

            if(players[i].addr.send(shareValue)) {
                // Throw an error if fails to send
                throw;
            }
            i++;
        }
    }
}

