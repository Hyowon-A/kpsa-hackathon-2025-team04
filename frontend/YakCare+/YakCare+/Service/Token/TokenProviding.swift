
import Foundation

protocol TokenProviding {
    var accessToken: String? { get set }
    /// 리프레시 토큰으로 새로운 accessToken을 요청하고, 완료 시 콜백을 호출한다.
    /// @escaing은 '이 함수가 return된 이후에, 네트워크 응답을 받은 시점에서 호출됨'을 의미한다.
    /// 성공 시 새로운 accessToken 문자열,, 실패 시 에러 객체를 입력 파라미터로 전달한다.
    func refreshToken(completion: @escaping (String?, Error?) -> Void)
}
