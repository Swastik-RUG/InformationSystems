pragma solidity >=0.4.22 <0.6.0;

contract CumulativeVoting {
    
    struct ShareHolder {
        bool authorized;
        bool voted;
        uint vote;
    }
    
    address private director;
    string public contract_title;
    
    mapping(address => ShareHolder) private ShareHolders;
    uint private totalVotes =0;
    uint private votesInFavour =0;

    modifier directorOnly() {
        // Assert before executing the body _;
        require(msg.sender == director);
        _;
    }
    
    function createContract(string memory _name) public {
        director = msg.sender;
        contract_title = _name;
    }
    
    function authorizeShareHolder(address _person) directorOnly public {
        ShareHolders[_person].authorized = true;
    }
    
    function unauthorizeShareHolder(address _person) directorOnly public {
        ShareHolders[_person].authorized = false;
    }
    
    function closeVoting() directorOnly public view returns(string memory) {
        if(votesInFavour > totalVotes/2)
            return "Majority: Agree";
        else
            return "Majority: Disagree";
    }
    
    function votingStatus() directorOnly public view returns (string memory) {
        if(votesInFavour > totalVotes/2)
            return "Voting is currently In Favour of the Contract";
        else
            return "Voting is currently Not In Favour of the Contract";
    }
    
    function vote(uint _voteStatus) public {
        require(!ShareHolders[msg.sender].voted);
        require(ShareHolders[msg.sender].authorized);
        require(_voteStatus == 0 || _voteStatus == 1);
        
        ShareHolders[msg.sender].vote = _voteStatus;
        ShareHolders[msg.sender].voted = true;
        totalVotes += 1;
        votesInFavour += _voteStatus;
    }
    
    function terminate() directorOnly public {
        selfdestruct(msg.sender);
    }

}