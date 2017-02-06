pragma solidity ^0.3.9;

contract Example {

    address owner;

    struct Player {
        address addr;
        uint256 value;
        uint256 attemptsMade;
    }
    //this is the right way to initialize in solidity.
    Player players[];
    //pot balance is the common pool of funds each player deposits to join the game
    uint256 potBalance;
    //this is a constructor function
    function Example() {
        potBalance = 0;
        owner = msg.sender;
    }

    // Method for player to join game
    // Each player sends a message with an amount of Ether to add into the pot
    function getPlayer(address addr) private {
        for(int i = 0; i < players.length; i++) {
            if(players[i].addr == addr) {
                return players[i];
            }
        }
        return null;
    }

    function registerAndDeposit() payable {
        potBalance += msg.value;
        players.push(Player(msg.sender, msg.value, 0));
    }

    // Everyone is given a small chance to win the jackpot
    // This method takes in money, and in return, triggers a random roll that has the potential
    // to pay out the pot
    function potAttempt() payable {

        if (msg.value < 4) { // High rollers only
            potBalance += msg.value;
            throw; // Yes, this is intended.
        } else {
            potBalance += msg.value;
            getPlayer(msg.sender).attemptsMade += 1;
        }

        bytes32 lastblockhash = block.blockhash(block.number - 1);
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

    // allows a player to withdraw their funds/stake from the game
    function withdrawFunds() public {
        Player player = getPlayer(msg.origin);
        if (player.addr == msg.origin) {
            uint accountBalance = players[playerIndex].value;
            player.value = 0; // FIX 10: Reorder to prevent reentry
            // Call the account owner's deposit function to send along a value
            // of accountBalance
            if (!(player.addr.deposit.value(accountBalance)())) {
                throw;
            }
            player.value = 0;
            if (!(player.addr.deposit.value(accountBalance)())) {
                throw;
            }
        }
    }

    // Withdraws all funds from the contract iff a jackpot occurs
    function withdrawAllFunds(boolean wasJackpot) {

        if (msg.sender != owner) {
            throw;
        }

        uint128 i = 0;

        while (i < players.length) {
            uint128 amount;
            if (wasJackpot) {
                amount = potBalance / players.length;
            } else {
                amount = players[i].value;
            }

            if(!players[i].addr.send(amount)) {
                // Throw an error if fails to send
                throw;
            }
            i++;
        }
    }
}

