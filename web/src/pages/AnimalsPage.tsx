import { useState } from 'react'
import { Button, Text, Stack } from '@mantine/core'
import { animalsRepository } from '../features/animals/animalsRepository'

export default function AnimalsPage() {
  const [response, setResponse] = useState('No response yet')
  const [loading, setLoading] = useState(false)

  const handleTest = async () => {
    setLoading(true)
    try {
      const result = await animalsRepository.fetchStatus()
      setResponse(result)
    } catch (e) {
      setResponse(`Error: ${e}`)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex items-center justify-center h-full">
      <Stack align="center">
        <Text>{response}</Text>
        <Button onClick={handleTest} loading={loading}>
          Test Backend
        </Button>
      </Stack>
    </div>
  )
}