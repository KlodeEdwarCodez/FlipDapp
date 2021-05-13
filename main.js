var web3 = new Web3(Web3.givenProvider);
var contractInstance;
var wager;
var id;

$(document).ready(function() {
    window.ethereum.enable().then(function(accounts){
        contractInstance = new web3.eth.Contract(abi, "0x555a8Cbf6A9B51947983C58DC0d558EBe23Aec5D", {from: accounts[0]});
        console.log(contractInstance);
    });

    $("#coinFlip").click(winLose);
    $("#get_wager").click(inputWager);
    $("#withdraw").click(withdrawAll);
  });


    function inputWager(){
        wager = $("#wager").val();

        var config = {
          value: web3.utils.toWei(wager, "ether")
        }

        contractInstance.methods.receiveEther().send(config)
        .on("transactionHash", function(hash){
            console.log(hash);
      })
        .on("confirmation", function(confirmatinoNr){
            console.log(confirmationNr);
      })
        .on("receipt", function(receipt){
            console.log(receipt);
      })
    }

    function winLose(){

      contractInstance.events.generatedRandomNumber(function(error,result){

          var choice = $("input[type='radio'][name='choices']:checked").val();
          id = result.returnValues.id;
          console.log(id,"Player's address");

          contractInstance.methods.findPlayer(id).call().then(function (player) {

              console.log(player.number, "the random number");
              console.log(player.playerAddress,"Players address");
              console.log(player.balance,"Players balance");
              console.log(player.isPlaying, "Is the player stil playing");

              if(player.number == 1 && choice == "heads"){

                  contractInstance.methods.winLose(true,id).call().then(function (balance){
                    $("#result_output").text("YOU WIN "+ wager +" coins.");
                    console.log("heads you win :"+ wager);
                  })
              }
              else if (player.number == 1 && choice != "heads") {
                  contractInstance.methods.winLose(false,id).call().then(function (balance){
                    $("#result_output").text("YOU LOSE " + wager + " coins.");
                    console.log("heads you lose :"+ wager);
                  })
              }
              else if (player.number == 0 && choice == "tail") {
                contractInstance.methods.winLose(true,id).call().then(function (balance){
                  $("#result_output").text("YOU WIN "+ wager +" coins.");
                  console.log("heads you win :"+ wager);
                })
              }
              else if (player.number == 0 && choice != "tail"){
                contractInstance.methods.winLose(false,id).call().then(function (balance){
                  $("#result_output").text("YOU LOSE " + wager + " coins.");
                  console.log("heads you lose :"+ wager);
                })
              }
          } )
      });

    }

    function withdrawAll(){

        contractInstance.methods.findPlayer(id).call().then(function(player){

          //$("#result_output2").text("Your balance "+parseFloat(player.balance).toFixed(2)+ " coins");

            contractInstance.methods.withdrawAll(id).call().then(function (exitingPlayer){

                $("#result_output").text("You are withdrawing your balance");
                $("#result_output3").text("Player's balance after withdrawal: "+parseFloat(exitingPlayer.balance).toFixed(2)+ " coins");

            })
        })

    }
