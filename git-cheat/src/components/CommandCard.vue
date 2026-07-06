<script setup>
import { RouterLink } from 'vue-router'

defineProps({
    command: {
        type: Object,
        require: true
    }
})
</script>

<template>
    <RouterLink :to="`/command/${command.slug}`" class="card">
        <h3 class="card-name">{{ command.name }}</h3>
        <p class="card-desc">{{ command.description }}</p>
    </RouterLink>
</template>

<style scoped src="../style.css"></style>