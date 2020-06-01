pragma solidity ^0.5.0;


contract dreamEleven {
    address creator;
    uint256 public CountEvents;

    // organizers
    struct Organizer {
        uint256 id;
        address orgAdr;
        uint256 Price;
        uint256 totalEther;
        address payable[] betters;
    }

    event OrganizerEventTriggered(
        uint256 id,
        address orgAdr,
        uint256 Price,
        uint256 totalEther,
        address payable[] betters
    );

    struct Better {
        uint256 id;
        address betterAddress;
    }

    constructor() public {
        creator = msg.sender;
    }

    // store organizers
    // mapping(address => address) public joinedBets;
    mapping(uint256 => Organizer) public organizers;
    mapping(address => uint256) public eventOrganizer;

    // mapping(address => mapping(uint => uint)) public BetsInMatch;

    function organizer(uint256 _price) external {
        CountEvents += 1;
        address payable[] memory a;
        organizers[CountEvents] = Organizer(
            CountEvents,
            msg.sender,
            _price,
            0,
            a
        );
        eventOrganizer[msg.sender] = CountEvents;
        emit OrganizerEventTriggered(CountEvents, msg.sender, _price, 0, a);
    }

    function joinBet(uint256 _id) external payable {
        Organizer storage _organizer = organizers[_id];
        // check the _id
        require(msg.value == _organizer.Price);
        if (msg.value < _organizer.Price) {
            revert();
        }
        _organizer.totalEther += msg.value;
        _organizer.betters.push(msg.sender);
        organizers[_id] = _organizer;
        emit OrganizerEventTriggered(
            _id,
            msg.sender,
            organizers[_id].Price,
            organizers[_id].totalEther,
            organizers[_id].betters
        );
    }

    function AnnounceResults() external {
        uint256 _id = eventOrganizer[msg.sender];
        Organizer memory _organizer = organizers[_id];
        require(
            msg.sender == _organizer.orgAdr,
            "you are not a organizer of this event"
        );
        require(_organizer.betters.length > 0);
        uint256 x = _randomModulo(_organizer.betters.length);
        address payable xx = _organizer.betters[x];
        xx.transfer(_organizer.totalEther);
    }

    function cancel(uint256 _id) external {
        Organizer memory _organizer = organizers[_id];
        address payable xx;
        for (uint256 i = 0; i < _organizer.betters.length; i++) {
            if (_organizer.betters[i] == msg.sender) {
                xx = _organizer.betters[i];
            }
        }
        xx.transfer(_organizer.Price);
    }

    function cancelLottery() external {
        uint256 _id = eventOrganizer[msg.sender];
        Organizer memory _organizer = organizers[_id];
        require(
            msg.sender == _organizer.orgAdr,
            "you are not a organizer of this event"
        );
        require(_organizer.betters.length > 0);
        address payable xx;
        for (uint256 i = 0; i < _organizer.betters.length; i++) {
            xx = _organizer.betters[i];
            xx.transfer(_organizer.Price);
            _organizer.totalEther -= _organizer.Price;
            xx = address(0);
        }
        organizers[_id] = _organizer;
    }

    function _randomModulo(uint256 modulo) internal view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.timestamp, block.difficulty))
            ) % modulo;
    }
}
