// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./zombiefactory.sol";

// 別のコントラクトを参照するインターフェース
abstract contract KittyInterface {
  function getKitty(uint256 _id) external view virtual returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {

    KittyInterface kittyContract;

    function setKittyContractAddress(address _address) external onlyOwner {
      kittyContract = KittyInterface(_address);
    }

    // ゾンビに餌をやり新しいゾンビを作成する関数
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal { // _zombieIdはインデックス番号
        // オーナーのみがゾンビに餌をあげれる
        require(msg.sender == zombieToOwner[_zombieId]);
        // 所有しているゾンビを取り出す
        Zombie storage myZombie = zombies[_zombieId];

        require(_isReady(myZombie));

        // _targetDnaを16桁に調整する
        _targetDna = _targetDna % dnaModulus;

        // 平均値を出す
        uint newDna = (myZombie.dna + _targetDna) / 2;

        // newDnaの末尾2桁を99に変更する
        if(keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
          newDna = newDna - newDna % 100 + 99;
        }
        // _createZombieを呼び新しいゾンビを配列に格納する
        _createZombie("NoName", newDna);

        _triggerCooldown(myZombie);
    }

    // 時間をセットする
    function _triggerCooldown(Zombie storage _zombie) internal {
      _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }

    function _isReady(Zombie storage _zombie) internal view returns(bool) {
      return (_zombie.readyTime <= block.timestamp);
    }

    // 別のコントラクトを参照し、新しいゾンビを作成する
    function feedOnlyKitty(uint _zombieId, uint _kittyId) public {
      uint kittyDna;
      (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);

      feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}