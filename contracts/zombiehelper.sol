// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

    modifier abovelevel(uint _level, uint _zombieId){
        require(zombies[_zombieId].level >= _level);
        _;
    }

    function changeName(uint _zombieId, string memory _newName) external abovelevel(2, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);

        zombies[_zombieId].name = _newName;
    }

    function changeDna(uint _zombieId, uint _newDna) external abovelevel(20, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);

        zombies[_zombieId].dna = _newDna;
    }

    function getZombiesByOwner(address _owner) external view returns(uint[] memory){
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
        if (zombieToOwner[i] == _owner) {
            result[counter] = i;
            counter++;
        }
        }
        return result;


    }
}