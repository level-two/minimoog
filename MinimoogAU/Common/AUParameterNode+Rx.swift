// -----------------------------------------------------------------------------
//    Copyright (C) 2019 Yauheni Lychkouski.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
// -----------------------------------------------------------------------------

import Foundation
import CoreAudioKit
import RxSwift

extension Reactive where Base: AUParameterNode {
    public func onParameter() -> Observable<(AUParameterAddress, AUValue)> {
        return Observable.create { observer in
            let parameterObserverToken = self.base.token(byAddingParameterObserver: { address, value in
                observer.on(.next((address, value)))
            })

            return Disposables.create {
                self.base.removeParameterObserver(parameterObserverToken)
            }
        }
    }
}
