import { useTelegram } from '../hooks/useTelegram'
import { MainButton } from '../components/MainButton'

export default function HomePage() {
  const { user, haptic } = useTelegram()
  
  const handleClick = () => {
    haptic.impactOccurred('medium')
    window.Telegram.WebApp.showAlert('Welcome to hello-world!')
  }
  
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">
        Welcome, {user?.first_name || 'User'}!
      </h1>
      
      <div className="bg-telegram-button/10 rounded-lg p-4 mb-4">
        <p className="text-telegram-hint">
          This is your Telegram Mini App. Start building amazing features!
        </p>
      </div>
      
      <MainButton text="Get Started" onClick={handleClick} />
    </div>
  )
}
