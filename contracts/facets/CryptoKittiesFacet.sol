// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

// Note: A facet is a contract used by a diamond.
// Note: This is a contrived example to show how to share internal functions between facets
// Note: It is not an accurate or complete implementation

// This design of sharing internal functions between facets works because remember the diamond proxy holds all the
// data and the facets read and write to the diamond proxy contract storage-- not to their own contract storage.

// The diamond proxy holds the data and the facets hold the code

// Normally a library like this would live in its own file and be imported into
// each facet that uses it.
library KittiesLib {
    
    struct AppStorage {  
        // owner address => (hatId => amount)      
        mapping(address => mapping(uint256 => uint256)) hatOwners;
        mapping(uint256 => uint256) kittiesToHats;
        mapping(uint256 => uint256) kittiesToGuilds;
        mapping(uint256 => bool) hatsForSale;

    } 

    function appStorage() internal pure returns (AppStorage storage s) {
        assembly { s.slot := 0 }
    }

    function isHatListedForSale(uint256 _hatId) internal view returns (bool) {
        AppStorage storage s = appStorage();
        return s.hatsForSale[_hatId];        
    }

    function getKittyGuild(uint256 _kittyId) internal view returns (uint256 guildId_) {
        AppStorage storage s = appStorage();
        guildId_ = s.kittiesToGuilds[_kittyId];
    }

    function transferHats(
        address _from,
        address _to,
        uint256 _hatId,
        uint256 _value
    ) internal {
        AppStorage storage s = appStorage();
        s.hatOwners[_from][_hatId] -= _value;
        s.hatOwners[_to][_hatId] += _value;        
        //... only showing partial implementation here        
    }
        
}

// KittiesLib internal functions are reused across facets.
// This works because each facet accesses the same contract storage -- the diamond proxy contract's contract storage
// Note that the diamond proxy source code is not here.
// Here's a link to a simple diamond proxy implementation: https://github.com/mudgen/diamond-1-hardhat

contract CryptoKittiesFacet {

    KittiesLib.AppStorage internal s;

    function attachHat(uint256 _kittyId, uint256 _hatId) external {
        require(!KittiesLib.isHatListedForSale(_hatId));
        require(KittiesLib.getKittyGuild(_kittyId) != 0, "Kitty not part of a guild.");
        s.kittiesToHats[_kittyId] = _hatId;        
        KittiesLib.transferHats(msg.sender, address(this), _hatId, 1);
    }

    // additional external functions exist of course, but not shown here

}

contract KittyHatsFacet {

    KittiesLib.AppStorage internal s;
    
    // Standard ERC1155 function here uses a shared internal function
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external {
        KittiesLib.transferHats(msg.sender, address(this), _id, 1);

        // only showing enough here to show a shared internal function being used
        // incomplete implementation here        
    }

    // additional external functions exist of course, but not shown here

}

contract MarketplaceFacet {

    KittiesLib.AppStorage internal s;

    function isHatListedForSale(uint256 _hatId) external view returns (bool) {
        return KittiesLib.isHatListedForSale(_hatId);
    }

    // additional external functions exist of course, but not shown here
}

contract GuildFacet {

   function getKittyGuild(uint256 _kittyId) internal view returns (uint256 guildId_) {
        guildId_ = KittiesLib.getKittyGuild(_kittyId);
    }

    // additional external functions exist of course, but not shown here
}