pragma solidity ^0.5.0;

contract Election{
    // candidates count increase
    uint256 public CandidatesCount;
    
    // make a candidate information struct
    struct Candidate{
        // candiate No
        uint id;
        // name
        string name;
        // votes
        uint voteCount;
    }
    // store candidates to particular id
    mapping(uint => Candidate) public candidates;
    // start election by adding condidates when smart contract will be deployed
    constructor() public{
        addCandidate("samarth");
        addCandidate("sanchit");
    }
    
    //make add condidate function
    function addCandidate(string memory _name) private{
        CandidatesCount+=1;
        candidates[CandidatesCount] = Candidate(CandidatesCount,_name,0);
    }
    
    // store the votes
    mapping(address => bool) public votes;
    
    // voting
    function vote(uint _id) external{
       // not given a vot
       require(!votes[msg.sender]);
       // the id exist
       require(_id > 0 && _id < CandidatesCount);
       // store the votes
       votes[msg.sender] = true;
       // increase the votes
       candidates[_id].voteCount++; 
    }
    
}
