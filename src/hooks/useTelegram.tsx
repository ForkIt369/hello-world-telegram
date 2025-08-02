import { createContext, useContext, useEffect, useState } from 'react'

interface TelegramUser {
  id: number
  first_name: string
  last_name?: string
  username?: string
  language_code?: string
}

interface TelegramContext {
  webApp: any
  user: TelegramUser | null
  haptic: {
    impactOccurred: (style: 'light' | 'medium' | 'heavy' | 'rigid' | 'soft') => void
    notificationOccurred: (type: 'error' | 'success' | 'warning') => void
    selectionChanged: () => void
  }
}

const TelegramContext = createContext<TelegramContext | null>(null)

export function TelegramProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<TelegramUser | null>(null)
  
  useEffect(() => {
    const tg = window.Telegram.WebApp
    setUser(tg.initDataUnsafe?.user || null)
  }, [])
  
  const value: TelegramContext = {
    webApp: window.Telegram.WebApp,
    user,
    haptic: {
      impactOccurred: (style) => window.Telegram.WebApp.HapticFeedback.impactOccurred(style),
      notificationOccurred: (type) => window.Telegram.WebApp.HapticFeedback.notificationOccurred(type),
      selectionChanged: () => window.Telegram.WebApp.HapticFeedback.selectionChanged()
    }
  }
  
  return (
    <TelegramContext.Provider value={value}>
      {children}
    </TelegramContext.Provider>
  )
}

export function useTelegram() {
  const context = useContext(TelegramContext)
  if (!context) {
    throw new Error('useTelegram must be used within TelegramProvider')
  }
  return context
}
