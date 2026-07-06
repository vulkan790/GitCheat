<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase.js'
import CommandCard from '../components/CommandCard.vue'

const commands = ref([])
const categories = ref([])
const search = ref('')
const activeCategory = ref(null)
const loading = ref(true)

onMounted(async () => {
    const [cmd, cat] = await Promise.all([
        supabase.from('commands').select('*, category:categories(name, slug)').order('name'),
        supabase.from('categories').select('*').order('name')
    ])
    commands.value = cmd.data ?? []
    categories.value = cat.data ?? []
    loading.value = false
})

const filtered = computed(() => {
    return commands.value.filter((c) => {
        const okSearch = c.name.toLowerCase().includes(search.value.toLowerCase())
        const okCat = !activeCategory.value || c.category?.slug === activeCategory.value
        return okSearch && okCat 
    })
})
</script>

<template>
    <div class="main-content">
        <div class="basic">
            <code class="main-par">Шпаргалка по git под рукой</code>
            <p class="sub-par">Найдите нужную команду за 2 секунды</p>
        </div>
        <input v-model="search" placeholder="🔍 git reset, отменить коммит..." />
        <div class="chips">
            <button 
                :class="{ active: !activeCategory }"
                @click="activeCategory = null">
                Все
            </button>
            <button
                v-for="cat in categories"
                :key="cat.id"
                :class="{ active: activeCategory === cat.slug }"
                @click="activeCategory = cat.slug">
                {{ cat.name }}
            </button>
        </div>
        <p v-if="loading" class="state">Загрузка...</p>
        <div v-else class="grid">
            <CommandCard 
                v-for="cmd in filtered"
                :key="cmd.id"
                :command="cmd"/>
        </div>
    </div>
</template>

<style scoped src="../style.css"></style>