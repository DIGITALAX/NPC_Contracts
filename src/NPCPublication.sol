// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.26;

import "./AutographAccessControl.sol";
import "./AutographCollection.sol";

enum LensType {
    Catalog,
    Comment,
    Publication,
    Autograph,
    Quote,
    Mirror
}

struct Publication {
    string tensors;
    address npc;
    uint256 collectionId;
    LensType lensType;
    bool boudica;
}

contract NPCPublication {
    AutographAccessControl public autographAccessControl;
    AutographData public autographData;
    string public symbol;
    string public name;
    uint8 public boudicaCount;
    uint256 private _callCount;
    bool private _activated;

    error AddressInvalid();

    event PublicationRegistered(
        address npc,
        uint256 profileId,
        uint256 pubId,
        LensType lensType
    );

    mapping(uint256 => mapping(uint256 => Publication)) private _publications;
    mapping(string => mapping(uint8 => string))
        private _boudicaPagesTextLanguage;
    mapping(address => mapping(LensType => uint256)) private _lensTypeByNPC;
    mapping(address => mapping(uint256 => uint256)) private _collectionByNPC;
    mapping(address => mapping(uint8 => uint256)) private _pageByNPC;
    mapping(address => mapping(string => mapping(uint8 => uint256)))
        private _boudicaPages;
    mapping(address => uint256) private _profileIds;

    constructor(
        string memory _symbol,
        string memory _name,
        address _autographAccessControl,
        address _autographData
    ) {
        symbol = _symbol;
        name = _name;
        _callCount = 0;
        autographAccessControl = AutographAccessControl(
            _autographAccessControl
        );
        _activated = false;
        autographData = AutographData(_autographData);
    }

    modifier NPCOnly() {
        if (!autographAccessControl.isNPC(msg.sender)) {
            revert AddressInvalid();
        }
        _;
    }

    modifier OnlyAdmin() {
        if (!autographAccessControl.isAdmin(msg.sender)) {
            revert AddressInvalid();
        }
        _;
    }

    function setBoudicaPagesText(
        string memory _pageText,
        string memory _language,
        uint8 _pageNumber
    ) public OnlyAdmin {
        _boudicaPagesTextLanguage[_language][_pageNumber] = _pageText;
    }

    function registerPublication(
        string memory _tensors,
        string memory _locale,
        uint256 _collection,
        uint256 _profileId,
        uint256 _pubId,
        uint8 _pageNumber,
        LensType _lensType,
        bool _boudica
    ) public NPCOnly {
        _publications[_profileId][_pubId].lensType = _lensType;
        _publications[_profileId][_pubId].collectionId = _collection;
        _publications[_profileId][_pubId].npc = msg.sender;
        _publications[_profileId][_pubId].tensors = _tensors;
        _publications[_profileId][_pubId].boudica = _boudica;
        _lensTypeByNPC[msg.sender][_lensType] += 1;

        if (_boudica) {
            _boudicaPages[msg.sender][_locale][_pageNumber] += 1;
        }

        if (_lensType == LensType.Catalog) {
            _pageByNPC[msg.sender][_pageNumber] += 1;
        } else if (_lensType == LensType.Autograph) {
            _collectionByNPC[msg.sender][_collection] += 1;
        }

        emit PublicationRegistered(msg.sender, _profileId, _pubId, _lensType);
    }

    function getPublicationType(
        uint256 _profileId,
        uint256 _pubId
    ) public view returns (LensType) {
        return _publications[_profileId][_pubId].lensType;
    }

    function getPublicationTensorData(
        uint256 _profileId,
        uint256 _pubId
    ) public view returns (string memory) {
        return _publications[_profileId][_pubId].tensors;
    }

    function getPublicationCollectionId(
        uint256 _profileId,
        uint256 _pubId
    ) public view returns (uint256) {
        return _publications[_profileId][_pubId].collectionId;
    }

    function getPublicationNPC(
        uint256 _profileId,
        uint256 _pubId
    ) public view returns (address) {
        return _publications[_profileId][_pubId].npc;
    }

    function getPublicationBoudica(
        uint256 _profileId,
        uint256 _pubId
    ) public view returns (bool) {
        return _publications[_profileId][_pubId].boudica;
    }

    function getBoudicaPageText(
        string memory _language,
        uint8 _pageNumber
    ) public view returns (string memory) {
        return _boudicaPagesTextLanguage[_language][_pageNumber];
    }

    function getPublicationPredictByNPC(
        string memory _locale,
        address _npcWallet,
        bool _boudica
    ) public returns (LensType, uint256, uint8, uint256) {
        uint256 _minCount1 = type(uint256).max;
        uint256 _minCount2 = type(uint256).max;
        LensType _minLensType1 = LensType.Comment;
        LensType _minLensType2 = LensType.Comment;

        LensType[] memory _lensTypes;

        if (_boudica) {
            _lensTypes = new LensType[](1);
            _lensTypes[1] = LensType.Catalog;
        } else {
            _lensTypes = new LensType[](6);
            _lensTypes[0] = LensType.Catalog;
            _lensTypes[1] = LensType.Comment;
            _lensTypes[2] = LensType.Publication;
            _lensTypes[3] = LensType.Autograph;
            _lensTypes[4] = LensType.Quote;
            _lensTypes[5] = LensType.Mirror;
        }

        if (!_boudica) {
            for (uint8 i = 0; i < _lensTypes.length; i++) {
                uint8 n = uint8(
                    uint256(keccak256(abi.encodePacked(block.timestamp, i))) %
                        _lensTypes.length
                );
                LensType temp = _lensTypes[i];
                _lensTypes[i] = _lensTypes[n];
                _lensTypes[n] = temp;
            }

            for (uint8 i = 0; i < _lensTypes.length; i++) {
                LensType _lensType = _lensTypes[i];
                uint256 _count = _lensTypeByNPC[_npcWallet][_lensType];

                if (_count < _minCount1) {
                    _minCount2 = _minCount1;
                    _minLensType2 = _minLensType1;
                    _minCount1 = _count;
                    _minLensType1 = _lensType;
                } else if (_count < _minCount2) {
                    _minCount2 = _count;
                    _minLensType2 = _lensType;
                }
            }
        }
        LensType chosenLensType;

        if (_boudica) {
            chosenLensType = LensType.Catalog;
        } else {
            if (_callCount % 2 == 0) {
                chosenLensType = _minLensType1;
            } else {
                chosenLensType = _minLensType2;
            }
        }

        _callCount++;
        if (
            chosenLensType == LensType.Publication ||
            !_activated ||
            (_callCount % 6 == 0 &&
                (chosenLensType == LensType.Comment ||
                    chosenLensType == LensType.Quote ||
                    chosenLensType == LensType.Mirror))
        ) {
            return (chosenLensType, 0, 0, 0);
        } else if (chosenLensType == LensType.Catalog) {
            uint8 _pageNumber = _findLeastPublishedPage(
                _locale,
                _npcWallet,
                _boudica
            );
            uint256 _profileId = autographData.getAutographProfileId();
            return (chosenLensType, 0, _pageNumber, _profileId);
        } else if (
            chosenLensType == LensType.Autograph ||
            chosenLensType == LensType.Mirror ||
            chosenLensType == LensType.Comment ||
            chosenLensType == LensType.Quote
        ) {
            (uint256 _selectedCollection, uint256 _profileId) = _handleStack(
                _npcWallet
            );

            if (_selectedCollection != uint256(0)) {
                return (chosenLensType, _selectedCollection, 0, _profileId);
            } else {
                if (_minLensType1 != LensType.Autograph) {
                    return (_minLensType1, 0, 0, 0);
                } else {
                    return (_minLensType2, 0, 0, 0);
                }
            }
        } else {
            return (chosenLensType, 0, 0, 0);
        }
    }

    function _findLeastPublishedArtistWithAvailableCollections(
        address _npcWallet
    ) internal view returns (uint256) {
        uint256[] memory collectionIds = autographData.getNPCToCollections(
            _npcWallet
        );
        uint256 minCount1 = type(uint256).max;
        uint256 minCount2 = type(uint256).max;
        uint256 minCollection1 = 1;
        uint256 minCollection2 = 1;

        for (uint256 i = 1; i < collectionIds.length; i++) {
            uint256 count = _collectionByNPC[_npcWallet][collectionIds[i]];
            if (count < minCount1) {
                minCount2 = minCount1;
                minCollection2 = minCollection1;
                minCount1 = count;
                minCollection1 = collectionIds[i];
            } else if (count < minCount2) {
                minCount2 = count;
                minCollection2 = collectionIds[i];
            }
        }

        if (minCollection1 != uint256(0)) {
            return minCollection1;
        } else {
            return minCollection2;
        }
    }

    function _findLeastPublishedPage(
        string memory _locale,
        address _npcWallet,
        bool _boudica
    ) internal view returns (uint8) {
        uint8 _pages = autographData.getAutographPageCount();
        if (_boudica) {
            _pages = boudicaCount;
        }

        uint256 minCount1 = type(uint256).max;
        uint256 minCount2 = type(uint256).max;
        uint8 minPage1 = 1;
        uint8 minPage2 = 1;

        for (uint8 i = 1; i < _pages; i++) {
            uint256 count = _pageByNPC[_npcWallet][i];
            if (_boudica) {
                count = _boudicaPages[_npcWallet][_locale][i];
            }

            if (count < minCount1) {
                minCount2 = minCount1;
                minPage2 = minPage1;
                minCount1 = count;
                minPage1 = i;
            } else if (count < minCount2) {
                minCount2 = count;
                minPage2 = i;
            }
        }

        if (block.timestamp % 2 == 0) {
            return minPage1;
        } else {
            return minPage2;
        }
    }

    function activatePublications() public OnlyAdmin {
        if (_activated) {
            _activated = false;
        } else {
            _activated = true;
        }
    }

    function setAutographData(address _autographData) public OnlyAdmin {
        autographData = AutographData(_autographData);
    }

    function setBoudicaPageCount(uint8 _pageCount) public OnlyAdmin {
        boudicaCount = _pageCount;
    }

    function setProfileIdDesigner(
        address _designer,
        uint256 _profileId
    ) public OnlyAdmin {
        _profileIds[_designer] = _profileId;
    }

    function _handleStack(
        address _npcWallet
    ) private view returns (uint256, uint256) {
        uint256 _selectedCollection = _findLeastPublishedArtistWithAvailableCollections(
                _npcWallet
            );

        uint16 _gId = autographData.getCollectionGallery(_selectedCollection);

        address _selectedArtist = autographData
            .getCollectionDesignerByGalleryId(_selectedCollection, _gId);

        if (_activated) {
            return (
                _selectedCollection,
                autographData.getDesignerProfileId(_selectedArtist)
            );
        } else {
            return (_selectedCollection, _profileIds[_npcWallet]);
        }
    }
}
