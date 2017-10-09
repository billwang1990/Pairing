
import AVFoundation
import CoreTelephony

final class SoundEffectManager {
    static let shareInstance = SoundEffectManager()
    var player: AVAudioPlayer?
    var audioSesstion: AVAudioSession?

    
    init() {
        audioSesstion = AVAudioSession.sharedInstance()
        let _ = try? audioSesstion?.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
    }
    
    func playEffect() {
        if let url = URL(string: Bundle.main.path(forResource: "shake_sound", ofType: "wav")!) {
            let _ = try? audioSesstion?.setActive(true)
            player = try! AVAudioPlayer(contentsOf: url)
            player?.play()
            player?.delegate = nil
        }
        
        let soundID = SystemSoundID(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(soundID)
    }
    
}

