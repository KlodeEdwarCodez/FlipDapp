import "./Ownable.sol";
pragma solidity >= 0.6.6 < 0.7.0;
import "./VRFConsumerBase.sol";
pragma experimental ABIEncoderV2;

contract Flip is Ownable, VRFConsumerBase{

    uint256 internal seed = block.difficulty;
    uint private balance;
    address public sender;
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    event LogNewProvableQuery(string description, bytes32 id);
    event generatedRandomNumber(string message, address id);

    mapping(address => player) public players;
    //mapping (address => bool) public isPlaying;

    struct player {
        address playerAddress;
        bytes32 id;
        uint balance;
        uint256 number;
        bool isPlaying;
    }

    modifier costs(uint cost){
        require(msg.value >= cost, "The minimum bet is 0.01 Ether");
        _;
    }

        constructor()
                    VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public {
            keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
            fee = 0.1 * 10 ** 18; // 0.1 LINK
        }

    function findPlayer(address id) public view returns (player memory){
        return players[id];
    }

    function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        require(players[sender].isPlaying==false);
        players[sender].isPlaying = true;
        emit LogNewProvableQuery("Provable query was sent, standing by for the answer. QUERY ID :", requestId);
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness % 2;
        players[sender].isPlaying = false;
        players[sender].number = randomResult;
        players[sender].id = requestId;
        emit generatedRandomNumber("RANDOM NUMBER GENERATED: ", sender);

    }

    function receiveEther() public payable costs(0.01 ether){
        require(address(this).balance >= msg.value, "The contract hasn't enought funds");
        sender = msg.sender;
        players [sender] = player (
          {
            playerAddress:sender,
            id:0,
            balance:msg.value,
            number:0,
            isPlaying:false
          }
        );
        getRandomNumber(seed);
    }

   function withdrawAll(address id) public returns(player memory) {
       uint toTransfer = players[id].balance;
       players[id].balance = 0;
       msg.sender.transfer(toTransfer);
       return players[id];
    }

   function winLose(bool winloss, address id) public returns(uint){

     uint playersBalance;

      if (winloss == true){
        players[id].balance += balance;
        playersBalance = players[id].balance;
      }
      else{
        players[id].balance -= balance;
        playersBalance = players[id].balance;
      }

      return playersBalance;
   }



}
