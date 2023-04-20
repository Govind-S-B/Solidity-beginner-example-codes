pragma solidity ^0.8.0;

contract VotingSystem {
    // Struct to represent a candidate
    struct Candidate {
        string name;
        uint voteCount;
    }

    // Array of candidates
    Candidate[] public candidates;

    // Mapping to keep track of whether an address has voted
    mapping(address => bool) public voters;

    // Function to add a candidate to the array of candidates
    function addCandidate(string memory _name) public {
        candidates.push(Candidate({
            name: _name,
            voteCount: 0
        }));
    }

    // Function to vote for a candidate
    function vote(uint _candidateIndex) public {
        // Ensure the voter has not already voted
        require(!voters[msg.sender], "You have already voted.");

        // Ensure the candidate index is valid
        require(_candidateIndex < candidates.length, "Invalid candidate index.");

        // Increment the candidate's vote count
        candidates[_candidateIndex].voteCount++;

        // Mark the voter as having voted
        voters[msg.sender] = true;
    }

    // Function to get the winning candidate
    function getWinner() public view returns (string memory) {
        uint winningVoteCount = 0;
        uint winningCandidateIndex;

        // Iterate through all candidates and find the one with the most votes
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateIndex = i;
            }
        }

        return candidates[winningCandidateIndex].name;
    }
}