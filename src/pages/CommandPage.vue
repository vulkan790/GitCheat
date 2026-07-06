<script setup>
import { ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../lib/supabase.js'

const route = useRoute()
const commands = ref([])
const loading = ref(true)
const notFound = ref(false)

async function loadCommand(slug)
{
    loading.value = true
    notFound.value = false
    
    const { data, error } = await supabase.from('commands').select('*, category:categories(name, slug), flags(*), examples(*)').eq('slug', slug).single()
    if (error || !data)
    {
        commands.value = null
        notFound.value = true
    }
    else
        commands.value = data
    loading.value = false
}

watch(() => route.params.slug, (slug) => loadCommand(slug), { immediate: true })
</script>

<template>
    <div class="main-content">
        <p v-if="loading" class="state">Загрузка...</p>
        <p v-else-if="notFound" class="state">Команда не найдена</p>
        <div v-else class="command">
            <p class="breadcrumbs">
                Категории / {{ commands.category?.name }} / {{ commands.slug }}
            </p>
            <h1 class="command-name">{{ commands.name }}</h1>
            <span v-if="commands.category" class="badge">{{ commands.category.name }}</span>
            <p class="description">{{ commands.description }}</p>
            <h2 class="section-title">Синтаксис</h2>
            <pre class="code-block"><code>{{ commands.syntax }}</code></pre>
            <template v-if="commands.flags.length">
                <h2 class="section-title">Частые флаги</h2>
                <div class="flags">
                    <div 
                        v-for="f in commands.flags"
                        :key="f.id"
                        class="flag-row">
                        <code class="flag-name">{{ f.flag }}</code>
                        <span class="flag-description"> {{  f.description }}</span>
                    </div>
                </div>
            </template>
            <template v-if="commands.examples.length">
                <h2 class="section-title">Примеры команды</h2>
                <div 
                    v-for="ex in commands.examples"
                    :key="ex.id"
                    class="example">
                    <p class="example-desc">{{ ex.description }}</p>
                    <pre class="code-block"><code>{{ ex.code }}</code></pre>
                </div>
            </template>
            <div v-if="commands.warning" class="warning">
                ⚠️ {{ commands.warning }}
            </div>
        </div>
    </div>
</template>

<style scoped src="../style.css"></style>