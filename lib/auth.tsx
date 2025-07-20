"use client"

import { createContext, useContext, useState, useEffect, type ReactNode } from "react"

export interface User {
  id: string
  username: string
  name: string
  role: "admin" | "user"
  rw?: string
  created_at?: string
  must_change_password?: boolean
  last_password_change?: string
}

interface AuthContextType {
  user: User | null
  login: (username: string, password: string) => Promise<boolean>
  register: (userData: RegisterData) => Promise<{ success: boolean; message: string }>
  logout: () => void
  changePassword: (oldPassword: string, newPassword: string) => Promise<{ success: boolean; message: string }>
  isLoading: boolean
}

export interface RegisterData {
  username: string
  password: string
  name: string
  rw: string
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

const ADMIN_USERS = [
  {
    id: "admin-rw01",
    username: "admin",
    name: "Ketua RW 01",
    role: "admin" as const,
    rw: "01",
    created_at: "2024-01-01T00:00:00Z",
    must_change_password: true,
    last_password_change: null,
  },
  {
    id: "admin-rw04",
    username: "admin",
    name: "Ketua RW 04",
    role: "admin" as const,
    rw: "04",
    created_at: "2024-01-01T00:00:00Z",
    must_change_password: true,
    last_password_change: null,
  },
]

const DEFAULT_ADMIN_PASSWORD = "admin"

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const savedUser = localStorage.getItem("auth_user")
    if (savedUser) {
      try {
        setUser(JSON.parse(savedUser))
      } catch (error) {
        localStorage.removeItem("auth_user")
      }
    }
    setIsLoading(false)
  }, [])

  const login = async (username: string, password: string): Promise<boolean> => {
    if (username === "admin") {
      if (password === DEFAULT_ADMIN_PASSWORD) {
        const rwChoice = prompt("Pilih RW Anda:\n1. RW 01\n2. RW 04\n\nMasukkan nomor pilihan (1 atau 2):")

        let selectedRW = ""
        if (rwChoice === "1") {
          selectedRW = "01"
        } else if (rwChoice === "2") {
          selectedRW = "04"
        } else {
          alert("Pilihan tidak valid. Pilih 1 untuk RW 01 atau 2 untuk RW 04.")
          return false
        }

        const adminUser = ADMIN_USERS.find((admin) => admin.rw === selectedRW)
        if (adminUser) {
          const adminPasswords = JSON.parse(localStorage.getItem("admin_passwords") || "{}")
          const hasCustomPassword = adminPasswords[adminUser.id]

          if (hasCustomPassword) {
            alert("Password default sudah diganti. Gunakan password baru Anda.")
            return false
          }

          setUser(adminUser)
          localStorage.setItem("auth_user", JSON.stringify(adminUser))
          return true
        }
      } else {
        const adminPasswords = JSON.parse(localStorage.getItem("admin_passwords") || "{}")

        for (const admin of ADMIN_USERS) {
          const customPassword = adminPasswords[admin.id]
          if (customPassword && password === customPassword) {
            const updatedAdmin = { ...admin, must_change_password: false }
            setUser(updatedAdmin)
            localStorage.setItem("auth_user", JSON.stringify(updatedAdmin))
            return true
          }
        }
      }
    }

    const users = JSON.parse(localStorage.getItem("registered_users") || "[]")
    const foundUser = users.find((u: any) => u.username === username && u.password === password)

    if (foundUser) {
      const { password: _, ...userWithoutPassword } = foundUser
      setUser(userWithoutPassword)
      localStorage.setItem("auth_user", JSON.stringify(userWithoutPassword))
      return true
    }

    return false
  }

  const register = async (userData: RegisterData): Promise<{ success: boolean; message: string }> => {
    if (userData.username === "admin") {
      return { success: false, message: "Username tidak tersedia" }
    }

    const users = JSON.parse(localStorage.getItem("registered_users") || "[]")
    const existingUser = users.find((u: any) => u.username === userData.username)

    if (existingUser) {
      return { success: false, message: "Username sudah digunakan" }
    }

    const newUser = {
      id: `user-${Date.now()}`,
      username: userData.username,
      password: userData.password,
      name: userData.name,
      role: "user" as const,
      rw: userData.rw,
      created_at: new Date().toISOString(),
    }

    users.push(newUser)
    localStorage.setItem("registered_users", JSON.stringify(users))

    return { success: true, message: "Registrasi berhasil! Silakan login." }
  }

  const logout = () => {
    setUser(null)
    localStorage.removeItem("auth_user")
  }

  const changePassword = async (
    oldPassword: string,
    newPassword: string,
  ): Promise<{ success: boolean; message: string }> => {
    if (!user) {
      return { success: false, message: "User tidak ditemukan" }
    }

    if (user.role === "admin") {
      const adminPasswords = JSON.parse(localStorage.getItem("admin_passwords") || "{}")
      const currentPassword = adminPasswords[user.id] || DEFAULT_ADMIN_PASSWORD

      if (oldPassword !== currentPassword) {
        return { success: false, message: "Password lama tidak benar" }
      }

      if (newPassword.length < 6) {
        return { success: false, message: "Password baru minimal 6 karakter" }
      }

      if (oldPassword === newPassword) {
        return { success: false, message: "Password baru harus berbeda dari password lama" }
      }

      adminPasswords[user.id] = newPassword
      localStorage.setItem("admin_passwords", JSON.stringify(adminPasswords))

      const updatedUser = {
        ...user,
        must_change_password: false,
        last_password_change: new Date().toISOString(),
      }
      setUser(updatedUser)
      localStorage.setItem("auth_user", JSON.stringify(updatedUser))

      return { success: true, message: "Password berhasil diubah" }
    } else {
      const users = JSON.parse(localStorage.getItem("registered_users") || "[]")
      const userIndex = users.findIndex((u: any) => u.id === user.id)

      if (userIndex === -1) {
        return { success: false, message: "User tidak ditemukan" }
      }

      if (oldPassword !== users[userIndex].password) {
        return { success: false, message: "Password lama tidak benar" }
      }

      if (newPassword.length < 6) {
        return { success: false, message: "Password baru minimal 6 karakter" }
      }

      if (oldPassword === newPassword) {
        return { success: false, message: "Password baru harus berbeda dari password lama" }
      }

      users[userIndex].password = newPassword
      users[userIndex].last_password_change = new Date().toISOString()
      localStorage.setItem("registered_users", JSON.stringify(users))

      return { success: true, message: "Password berhasil diubah" }
    }
  }

  const contextValue = {
    user,
    login,
    register,
    logout,
    changePassword,
    isLoading,
  }

  return <AuthContext.Provider value={contextValue}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider")
  }
  return context
}

// Hapus export default AuthProvider
// export default AuthProvider; // <--- Hapus baris ini
