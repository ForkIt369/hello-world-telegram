import { useEffect } from 'react'

interface MainButtonProps {
  text: string
  onClick: () => void
  disabled?: boolean
  progress?: boolean
}

export function MainButton({ text, onClick, disabled = false, progress = false }: MainButtonProps) {
  useEffect(() => {
    const tg = window.Telegram.WebApp
    
    tg.MainButton.setText(text)
    tg.MainButton.show()
    
    if (progress) {
      tg.MainButton.showProgress()
    } else {
      tg.MainButton.hideProgress()
    }
    
    if (disabled) {
      tg.MainButton.disable()
    } else {
      tg.MainButton.enable()
    }
    
    tg.MainButton.onClick(onClick)
    
    return () => {
      tg.MainButton.hide()
      tg.MainButton.offClick(onClick)
    }
  }, [text, onClick, disabled, progress])
  
  return null
}
