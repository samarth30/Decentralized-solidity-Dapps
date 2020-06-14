pragma solidity ^0.5.0;

contract Loan{
   uint public amount;
   uint public interest;
   uint public end;
   address payable public lender;
   address payable public borrower;
 
   
   
  constructor(uint _interest,uint _duration)public{
      interest = _interest;
      end = now + _duration;
      lender = msg.sender;
  }
   
   function lendIt(address payable to) external payable onlyLender(){
       if(msg.value  < 1 ether){
           revert();
       }
       borrower = to;
       amount = msg.value;
       to.transfer(msg.value);
   }
   
   function calc(uint _interest) public view returns(uint){
        return (amount/100)*_interest;
   }
   
   function reimberse() payable external onlyBorrower(){
       if(msg.value < amount+calc(interest)){
           revert();
       }
       lender.transfer(msg.value);
   }

   modifier onlyLender(){
       require(msg.sender == lender);
       _;
   }
   
   modifier onlyBorrower(){
       require(msg.sender == borrower);
       _;
   }
}
