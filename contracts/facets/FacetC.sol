// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library LibA {

    // This struct contains state variables we care about.
        struct DiamondStorage {
            bytes32 dataA;
            uint256 digits;
            address owner;
            uint256 new_digits;
        }

        // Returns the struct from a specified position in contract storage
        // ds is short for DiamondStorage
        function diamondStorage() internal pure returns(DiamondStorage storage ds) {
            // Specifies a random position from a hash of a string
            bytes32 storagePosition = keccak256("diamond.storage.LibA");
            // Set the position of our struct in contract storage
            assembly {
            ds.slot := storagePosition
            }
        }
}

    // Our facet uses the diamond storage defined above.
contract FacetC {

    function setDataC(bytes32 _dataA, uint _dig) external {
        LibA.DiamondStorage storage ds = LibA.diamondStorage();
        ds.dataA = _dataA;
        ds.digits = _dig;
        ds.owner = msg.sender;
    }

    function getDataC() external view returns (LibA.DiamondStorage memory) {

        LibA.DiamondStorage storage  ds = LibA.diamondStorage();
        require(ds.owner == msg.sender, "Must be owner.");
        return ds;
        
    }

}