<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase.js'

const commands = ref([])
const topics = ref([])
const activeTopic = ref('all')
const query = ref('')
const loading = ref(null)
const loadEsrror = ref(null)

onMounted(async () => {
    const [cmdRes, topicRes] = await Promise.all([
        supabase.from('commands').select('name, slug, description, category:categories(topic:topics(slug, name))').order('name'),
        supabase.from('topics').select('name, slug').order('id')
    ])

    if (cmdRes.error || topicRes.error)
        loadError.value = true
    else
    {
        commands.value = (cmdRes.data ?? []).filter(c => c.category?.topics?.slug)
        topics.value = topicRes.data ?? []
    }

    loading.value = false
})

const filtered = computed(() => {
    const q = query.value.trim().toLowerCase()
    return commands.value.filter(c => {
        const byTopic = activeTopic.value === 'all' || c.category.topic.slug === activeTopic.value
        const byQuery = !q || c.name.toLowerCase().includes(q) || (c.description ?? '').toLowerCase().includes(q)
        return byTopic && byQuery
    })
})
</script>

<template>
    <div class="main-content">
        <div class="basic">
            <div class="main-par">Справочник разработчика</div>
        </div>
    </div>
</template>

<style scoped src="../style.css"></style>