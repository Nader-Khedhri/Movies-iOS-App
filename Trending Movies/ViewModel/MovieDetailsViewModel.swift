//
//  MovieDetailsViewModel.swift
//  Trending Movies
//
//  Created by Nader Khedhri on 17/05/2022.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class MovieDetailsViewModel {
    
    var loadingBehavior = BehaviorRelay<Bool>(value: false)
    private var movieDetailsModelSubject = PublishSubject<MovieDetailsModel>()
    
    var movieDetailsModelObservable: Observable<MovieDetailsModel> {
        return movieDetailsModelSubject
    }
    
    func getMovieDetails(idMovie: Int) {

        let parameters = ["api_key": Constants.apiKey]
        let url = "https://api.themoviedb.org/3/movie/\(idMovie)"
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        let encoding = URLEncoding.queryString

        loadingBehavior.accept(true)
        APIServices.instance.getData(url: url, method: .get, params: parameters, encoding: encoding, headers: headers) { [weak self](movieDetailsModel: MovieDetailsModel?, errorModel: BaseErrorModel?, error) in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            if let error = error {
                print(error.localizedDescription)
            } else if let errorModel = errorModel {
                print(errorModel.status_message ?? "")
            } else {
                guard let movieDetailsModel = movieDetailsModel else { return }
                self.movieDetailsModelSubject.onNext(movieDetailsModel )
            }
        }
    }
}
