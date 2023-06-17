//
//  SinglePostCellType.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/16/23.
//

import Foundation

enum SinglePostCellType {
    case poster(viewModel: PosterCollectionViewCellViewModel)
    case post(viewModel: PostCollectionViewCellViewModel)
    case actions(viewModel: PostActionsCollectionViewCellViewModel)
    case likeCount(viewModel: PostLikesCollectionViewCellViewModel)
    case caption(viewModel: PostCaptionCollectionViewCellViewModel)
    case timestamp(viewModel: PostDatetimeCollectionViewCellViewModel)
    case comment(viewModel: [Comment])
}
