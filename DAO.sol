pragma solidity ^0.5.0;

contract DAO{
    
    uint public time = now;
    
    struct Proposal{
        uint id;
        string name;
        uint amount;
        address payable recepient;
        uint votes;
        uint end;
        bool executed;
    }
 
    mapping(address => bool) public investors;
    mapping(address => uint) public shares;
    
    // mapping for the Proposal
    mapping(uint => Proposal) public proposals;
    
    // mapping to store vote for the candidate to vote once
    mapping(address =>mapping(uint => bool)) public votes;
    
    uint256 public avaliableFunds;
    uint256 public totalShares;
    uint256 public contributionEnd;
    uint256 public proposalCount;
    
    uint public voteTime;
    address public admin;
    uint public quorum;
    constructor(uint contributionTime,uint256 _voteTime,uint256 _quorum) public{
        require(_quorum >0 && _quorum <= 100,"it must be betwreen 0 and 100");
        contributionEnd = now + contributionTime;
        voteTime = _voteTime;
        quorum = _quorum;
        admin = msg.sender;
    }
    
    function contribute() external payable{
        require(now < contributionEnd,"the contributon period has overed");
        investors[msg.sender] = true;
        shares[msg.sender] += msg.value;
        totalShares += msg.value;
        avaliableFunds+= msg.value;
    }
    
    function redeemShare(uint256 amount) external{
        require(shares[msg.sender] >= amount,"your account dont have enough shares");
        require(avaliableFunds >= amount,"there are not avaliable funds present right now");
        shares[msg.sender] -= amount;
        avaliableFunds -= amount;
        msg.sender.transfer(amount);
    }
    
    function transferShare(uint256 amount,address to) external{
        require(shares[msg.sender] >= amount,"not have sufficent shares");
        
        shares[msg.sender] -= amount;
        shares[to] += amount;
        investors[to] = true;
    }
    
    function createProposal(string memory name,uint amount,address payable recepient) public onlyInvestor {
        require(avaliableFunds >= amount);
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount,name,amount,recepient,0,now+voteTime,false);
    }
    
    function vote(uint _id) external onlyInvestor{
        Proposal storage _proposal = proposals[_id];
        require(votes[msg.sender][_id] == false);
        require(now < _proposal.end);
        votes[msg.sender][_id] = true;
        _proposal.votes+=shares[msg.sender];
    }
    
    function executeProposal(uint _id) external onlyAdmin{
         Proposal storage _proposal = proposals[_id];
         require(now > _proposal.end);
         require(_proposal.executed == false);
         require((_proposal.votes/totalShares) *100 >= quorum);
         _proposal.executed = false;
         _transferEther(_proposal.amount,_proposal.recepient);
    }
    
    function _transferEther(uint amount ,address payable _recepient) internal{
        require(avaliableFunds>= amount);
        avaliableFunds-=amount;
        _recepient.transfer(amount);
    }
    
    function cancelProposal(uint _id) external payable onlyInvestor(){
        Proposal memory _proposal = proposals[_id];
        require(msg.sender == _proposal.recepient);
        if(msg.value != _proposal.amount){
            revert();
        }
    }
    
    modifier onlyInvestor(){
        require(investors[msg.sender] == true,"you are not a investor");
        _;
    }
    
    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }
}  

