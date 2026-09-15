<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { supabase } from '../lib/supabase.js'
import { applyTheme, THEMES } from '../lib/themes.js'
import CommandCard from '../components/CommandCard.vue'

const commands = ref([])
const topics = ref([])
const activeTopic = ref('git')
const search = ref('')
const loading = ref(true)

const colorOf = (slug) => THEMES[slug]?.accent ?? '#888888'
const activeName = computed(() => topics.value.find(t => t.slug === activeTopic.value)?.name ?? '')

watch(activeTopic, (slug) => applyTheme(slug), { immediate: true })

onMounted(async () => {
    const [cmd, top] = await Promise.all([
        supabase.from('commands').select('*, category:categories(name, slug, topic:topics(slug, name))').order('name'),
        supabase.from('topics').select('*').order('id')
    ])
    commands.value = (cmd.data ?? []).filter(c => c.category?.topic?.slug)
    topics.value = top.data ?? []
    loading.value = false
})

const filtered = computed(() => {
    const q = search.value.toLowerCase()
    return commands.value.filter((c) => {
        const okSearch = c.name.toLowerCase().includes(q)
        const okTopic = c.category?.topic?.slug === activeTopic.value
        return okSearch && okTopic
    })
})
</script>

<template>
    <div class="main-content">
        <div class="basic">
            <code class="main-par">Шпаргалка разработчика под рукой</code>
            <p class="sub-par">Найдите нужную команду за 2 секунды</p>
        </div>
        <input v-model="search" placeholder="🔍 git reset, отменить коммит, docker run..." />
        <div class="topic-dots">
            <button
                v-for="t in topics"
                :key="t.slug"
                class="topic-dot"
                :class="{ active: activeTopic === t.slug }"
                :style="{ '--dot': colorOf(t.slug) }"
                :title="t.name"
                :aria-label="t.name"
                @click="activeTopic = t.slug" 
            />
        </div>
        <p v-if="loading" class="state">Загрузка...</p>
        <div v-else-if="!filtered.length" class="state">
            {{ search ? 'Ничего не найдено' : 'В этой теме пока нет команд' }}
        </div>
        <div v-else class="grid">
            <CommandCard 
                v-for="cmd in filtered"
                :key="cmd.id"
                :command="cmd"/>
        </div>
    </div>
</template>