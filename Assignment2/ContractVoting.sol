pragma solidity >=0.4.22 <0.6.0;

contract CumulativeVoting {
    
    /*
    * A structure to hold ShareHolders vote status and his voting rights (authorized)
    * @authorized -> A boolean flag indicating if a ShareHolder is allowed to vote or Not
    * @voted -> A boolean flag indicating if the ShareHolder has already voted.
    */
    struct ShareHolder {
        bool authorized;
        bool voted;
    }
    
    // Stores the directors address.
    address private director;
    
    // Stores the Question's title or description.
    string public Question;
    
    bool private votingInProgress = false;
    bool private electionResult = false;
    
    // Creates a map object (addressOfShareHolder -> ShareHolder struct), to keep track of shareholders voting.
    mapping(address => ShareHolder) private ShareHolders;
    address[] private addressLookupTable;
    
    // Stores the total number for votes cast in the ballot.
    uint private totalVotes = 0;
    
    // Stores the total number of votes in favour of the Question proposed.
    uint private votesInFavour = 0;
    
    /*
    * Reusable assert functionality to restrict access to the resources to ShareHolders except the director.
    */
    modifier directorOnly() {
        // Assert/require before executing the body _;
        require(msg.sender == director);
        _;
    }
    
    modifier isVotingInProgress() {
        require(votingInProgress == true);
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
    * Create a new Question.
    * @_name -> Title/Description of the Question.
    */
    function createQuestion(string memory _name) directorOnly public {
       /* Set the Question's Title/Description */
        Question = _name;
        votingInProgress = true;
        votesInFavour = 0;
        totalVotes = 0;
    }
    
    /*
    * Give the right of voting to a ShareHolder.
    * @_shareholder -> The address of the ShareHolder to whom voting right should be provided.
    */
    function authorizeShareHolder(address _shareholder) directorOnly public {
        /* Set the authorized boolean flag for the shareholder as true */
        ShareHolders[_shareholder].authorized = true;
        addressLookupTable.push(_shareholder);
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
    * Close the voting activity on the Question.
    */
    function VotingResults() public view returns(string memory) {
        /* Check if votes in favour of Question is greater than 50% of the total votes */
        if(!votingInProgress) {
            if(electionResult)
                return "Majority: Agree";
            else
                return "Majority: Disagree";
        } else return "Voting is still in progress: end the voting";
    }
    
    /*
    * Function to stop the voting process. Any votes cast after the invocation of this function will be ignored.
    */
    function endVoting() directorOnly public {
        electionResult = votesInFavour > totalVotes/2;
        votingInProgress = false;
        Question = "--Create a new Question to begin Voting--";
        for (uint i=0; i< addressLookupTable.length ; i++) {
            ShareHolders[addressLookupTable[i]].voted = false;
        }
    }
    
    /*
    * View the status of voting activity on the Question.
    */
    function votingStatus() directorOnly public view returns (string memory) {
        /* Check if votes in favour of Question is greater than 50% of the total votes */
        if(votingInProgress) {
            if(votesInFavour > totalVotes/2)
                return "Voting is currently In Favour of the Question";
            else
                return "Voting is currently Not In Favour of the Question";
        }
        else
            return "No Active Questions being voted: Voting ended! use VotingResults";
    }
    
    /*
    * Function that allows the ShareHolders to cast their vote.
    * @_voteStatus -> A boolean value 0/1 that can be cast by the shareholders; 0 -> Disagree, 1 -> Agree.
    */
    function vote(uint _voteStatus) public isVotingInProgress {
        
        /* Check if the ShareHolder casting the vote has already voted */
        require(!ShareHolders[msg.sender].voted);
        
        /* Check if the ShareHolder casting the vote is authorized to vote */
        require(ShareHolders[msg.sender].authorized);
        
        /* Check if the vote casted by the ShareHolder is a valid binary (0|1) */
        require(_voteStatus == 0 || _voteStatus == 1);
        
        
        /* Flip the voted flag of the ShareHolder to block them from casting a duplicate vote */
        ShareHolders[msg.sender].voted = true;
        
        /*
        * @totalVotes -> Total number of votes casted in the ballot.
        * @votesInFavour -> Total number of votes in favour of the Question.
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