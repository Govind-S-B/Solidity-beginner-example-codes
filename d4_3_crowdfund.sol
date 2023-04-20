pragma solidity ^0.8.0;

contract Crowdfunding {
    struct Campaign {
        address creator;          // Address of the campaign creator
        uint256 goal;             // Funding goal in wei
        uint256 raised;           // Total amount raised in wei
        mapping(address => uint256) contributions; // Contributions by individual contributors
        bool closed;             // Flag to indicate if the campaign is closed
        bool refundable;         // Flag to indicate if the campaign is refundable
    }

    mapping(uint256 => Campaign) private campaigns; // Campaigns mapping, using campaign ID as key
    uint256 private campaignId; // Auto-incrementing campaign ID

    event CampaignCreated(uint256 campaignId, address creator, uint256 goal);
    event ContributionAdded(uint256 campaignId, address contributor, uint256 amount);
    event CampaignClosed(uint256 campaignId, uint256 raised, bool refundable);
    event RefundClaimed(uint256 campaignId, address contributor, uint256 amount);
    event CampaignRefunded(uint256 campaignId);

    function createCampaign(uint256 _goal) public {
        require(_goal > 0, "Goal must be greater than zero");
        campaignId++;
        Campaign storage campaign = campaigns[campaignId];
        campaign.creator = msg.sender;
        campaign.goal = _goal;
        campaign.raised = 0;
        campaign.closed = false;
        campaign.refundable = false;
        emit CampaignCreated(campaignId, msg.sender, _goal);
    }

    function contribute(uint256 _campaignId) public payable {
        require(!campaigns[_campaignId].closed, "Campaign is closed");
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.goal > 0, "Campaign does not exist");
        campaign.contributions[msg.sender] += msg.value;
        campaign.raised += msg.value;
        if (campaign.raised >= campaign.goal && !campaign.refundable) {
            campaign.refundable = true;
        }
        emit ContributionAdded(_campaignId, msg.sender, msg.value);
    }

    function closeCampaign(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.creator == msg.sender, "Only campaign creator can close the campaign");
        require(!campaign.closed, "Campaign is already closed");
        campaign.closed = true;
        if (campaign.raised >= campaign.goal) {
            campaign.refundable = false;
        }
        emit CampaignClosed(_campaignId, campaign.raised, campaign.refundable);
    }

    function claimRefund(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.closed, "Campaign is not closed");
        require(campaign.refundable, "Campaign is not refundable");
        uint256 contribution = campaign.contributions[msg.sender];
        require(contribution > 0, "No contribution found for the sender");
        campaign.contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contribution);
        emit RefundClaimed(_campaignId, msg.sender, contribution);
    }

    function getCampaign(uint256 _campaignId) public view returns (address, uint256, uint256, bool, bool) {
        Campaign storage campaign = campaigns[_campaignId];
        return (campaign.creator, campaign.goal, campaign.raised, campaign.closed, campaign.refundable);
    }

    function getContribution(uint256 _campaignId, address _contributor) public view returns (uint256) {
        Campaign storage campaign = campaigns[_campaignId];
        return campaign.contrib
