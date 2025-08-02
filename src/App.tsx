import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { TelegramProvider } from './hooks/useTelegram'
import HomePage from './pages/HomePage'
import './App.css'

function App() {
  return (
    <TelegramProvider>
      <Router>
        <div className="min-h-screen bg-telegram-bg text-telegram-text">
          <Routes>
            <Route path="/" element={<HomePage />} />
          </Routes>
        </div>
      </Router>
    </TelegramProvider>
  )
}

export default App
