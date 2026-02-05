<script setup lang="ts">
import {
  BadgeCheck,
  Bell,
  ChevronsUpDown,
  CreditCard,
  LogOut,
  Sparkles,
} from 'lucide-vue-next'
import { useSidebar } from '~/components/ui/sidebar'

withDefaults(
  defineProps<{
    user?: {
      name?: string
      email?: string
      avatar?: string
    }
  }>(),
  {
    user: () => ({ name: 'User', email: 'user@example.com', avatar: undefined }),
  },
)

const { isMobile } = useSidebar()
const { theme, toggleTheme } = useTheme()
</script>

<template>
  <SidebarMenu>
    <SidebarMenuItem>
      <DropdownMenu :modal="false">
        <DropdownMenuTrigger as-child>
          <SidebarMenuButton
            size="lg"
            class="data-[state=open]:bg-sidebar-accent data-[state=open]:text-sidebar-accent-foreground"
          >
            <Avatar class="h-8 w-8 rounded-lg">
              <AvatarImage
                v-if="user.avatar"
                :src="user.avatar"
                :alt="user.name"
              />
              <AvatarFallback class="rounded-lg">
                {{ user.name?.slice(0, 2).toUpperCase() ?? 'US' }}
              </AvatarFallback>
            </Avatar>
            <div class="grid flex-1 text-left text-sm leading-tight">
              <span class="truncate font-medium">{{ user.name }}</span>
              <span class="truncate text-xs">{{ user.email }}</span>
            </div>
            <ChevronsUpDown class="ml-auto size-4" />
          </SidebarMenuButton>
        </DropdownMenuTrigger>
        <DropdownMenuContent
          class="min-w-56 rounded-lg"
          :side="isMobile ? 'bottom' : 'right'"
          align="end"
          :side-offset="4"
        >
          <DropdownMenuLabel class="p-0 font-normal">
            <div class="flex items-center gap-2 px-1 py-1.5 text-left text-sm">
              <Avatar class="h-8 w-8 rounded-lg">
                <AvatarImage
                  v-if="user.avatar"
                  :src="user.avatar"
                  :alt="user.name"
                />
                <AvatarFallback class="rounded-lg">
                  {{ user.name?.slice(0, 2).toUpperCase() ?? 'US' }}
                </AvatarFallback>
              </Avatar>
              <div class="grid flex-1 text-left text-sm leading-tight">
                <span class="truncate font-semibold">{{ user.name }}</span>
                <span class="truncate text-xs">{{ user.email }}</span>
              </div>
            </div>
          </DropdownMenuLabel>
          <DropdownMenuSeparator />
          <DropdownMenuGroup>
            <DropdownMenuItem>
              <Sparkles class="size-4" />
              Upgrade to Pro
            </DropdownMenuItem>
          </DropdownMenuGroup>
          <DropdownMenuSeparator />
          <DropdownMenuGroup>
            <DropdownMenuItem>
              <BadgeCheck class="size-4" />
              Account
            </DropdownMenuItem>
            <DropdownMenuItem>
              <CreditCard class="size-4" />
              Billing
            </DropdownMenuItem>
            <DropdownMenuItem>
              <Bell class="size-4" />
              Notifications
            </DropdownMenuItem>
            <DropdownMenuItem @click="toggleTheme">
              <Icon
                :name="theme.icon"
                class="size-4"
              />
              {{ theme.label }}
            </DropdownMenuItem>
          </DropdownMenuGroup>
          <DropdownMenuSeparator />
          <DropdownMenuItem @click="navigateTo('/')">
            <LogOut class="size-4" />
            Log out
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </SidebarMenuItem>
  </SidebarMenu>
</template>
