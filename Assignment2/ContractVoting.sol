pragma solidity >=0.4.22 <0.6.0;

contract CumulativeVoting {
    
    /*
    * A structure to hold ShareHolders vote status and his voting rights (authorized)
    * @authorized -> A boolean flag indicating if a ShareHolder is allowed to vote or Not
    * @voted -> A boolean flag indicating if the ShareHolder has already voted.
    * @vote -> An integer variable that indicated the vote placed by the ShareHolder this is either 0 or 1.
    */
    struct ShareHolder {
        bool authorized;
        bool voted;
        uint vote;
    }
    
    // Stores the directors address.
    address private director;
    
    // Stores the contracts title or description or contract.
    string public contract_title;
    
    // Creates a map object (addressOfShareHolder -> ShareHolder struct), to keep track of shareholders voting.
    mapping(address => ShareHolder) private ShareHolders;
    
    // Stores the total number for votes cast in the ballot.
    uint private totalVotes = 0;
    
    // Stores the total number of votes in favour of the contract proposed.
    uint private votesInFavour = 0;
    
    /*
    * Reusable assert functionality to restrict access to the resources to ShareHolders except the director.
    */
    modifier directorOnly() {
        // Assert/require before executing the body _;
        require(msg.sender == director);
        _;
    }
    
    /* Override the constructor to initialize the director on startup */
    constructor () public {
        /* msg.sender -> Contains the address of the address that deployed the contract.
        * Save the address of the deployer as director
        */
        director = msg.sender;
    }
    
    /*
    * Create a new Contract.
    * @_name -> Title/Description of the Contract.
    */
    function createContract(string memory _name) directorOnly public {
       /* Set the contract's Title/Description */
        contract_title = _name;
    }
    
    /*
    * Give the right of voting to a ShareHolder.
    * @_shareholder -> The address of the ShareHolder to whom voting right should be provided.
    */
    function authorizeShareHolder(address _shareholder) directorOnly public {
        /* Set the authorized boolean flag for the shareholder as true */
        ShareHolders[_shareholder].authorized = true;
    }
    
    /*
    * Retract the right of voting from a ShareHolder.
    * @_shareholder -> The address of the ShareHolder to whom voting right should be retracted.
    */
    function unauthorizeShareHolder(address _shareholder) directorOnly public {
        /* Set the authorized boolean flag for the shareholder as false */
        ShareHolders[_shareholder].authorized = false;
    }
    
    /*
    * Close the voting activity on the Contract.
    */
    function closeVoting() directorOnly public view returns(string memory) {
        /* Check if votes in favour of contract is greater than 50% of the total votes */
        if(votesInFavour > totalVotes/2)
            return "Majority: Agree";
        else
            return "Majority: Disagree";
    }
    
    /*
    * View the status of voting activity on the Contract.
    */
    function votingStatus() directorOnly public view returns (string memory) {
        /* Check if votes in favour of contract is greater than 50% of the total votes */
        if(votesInFavour > totalVotes/2)
            return "Voting is currently In Favour of the Contract";
        else
            return "Voting is currently Not In Favour of the Contract";
    }
    
    /*
    * Function that allows the ShareHolders to cast their vote.
    * @_voteStatus -> A boolean value 0/1 that can be cast by the shareholders; 0 -> Disagree, 1 -> Agree.
    */
    function vote(uint _voteStatus) public {
        
        /* Check if the ShareHolder casting the vote has already voted */
        require(!ShareHolders[msg.sender].voted);
        
        /* Check if the ShareHolder casting the vote is authorized to vote */
        require(ShareHolders[msg.sender].authorized);
        
        /* Check if the vote casted by the ShareHolder is a valid binary (0|1) */
        require(_voteStatus == 0 || _voteStatus == 1);
        
        /* Record the vote casted by the ShareHolder */
        ShareHolders[msg.sender].vote = _voteStatus;
        
        /* Flip the voted flag of the ShareHolder to block them from casting a duplicate vote */
        ShareHolders[msg.sender].voted = true;
        
        /*
        * @totalVotes -> Toatal number of votes casted in the ballot.
        * @votesInFavour -> Total number of votes in favour of the Contract.
        */
        totalVotes += 1;
        votesInFavour += _voteStatus;
    }
    
    /*
    * Function to deinitalize the director and selfdestruct the Contract application.
    */
    function terminate() directorOnly public {
        selfdestruct(msg.sender);
    }

}