<template>
  <div class="app-container">
    <el-card header="系统资源优化建议（基于使用率与舒适度）">
      <ul class="lines">
        <li v-for="(t,i) in lines" :key="i">{{ t }}</li>
      </ul>
      <el-button type="primary" size="small" @click="load">刷新</el-button>
    </el-card>
  </div>
</template>

<script>
import { suggestList } from '@/api/thesis/admin'
export default {
  name: 'ThesisSuggest',
  data() { return { lines: [] } },
  created() { this.load() },
  methods: {
    load() {
      suggestList().then(r => { this.lines = (r.data && r.data.lines) || [] })
    }
  }
}
</script>

<style scoped>
.lines li { margin: 8px 0; line-height: 1.6; }
</style>
