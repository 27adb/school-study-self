<script>
export default {
  onLaunch() {
    // 预约状态维护应由后端定时任务执行。
    // 前端启动阶段不再发起全局维护请求，避免在网络波动或未登录时触发连锁超时。
  },
}
</script>

<style lang="scss">
/* 微信小程序不支持 * 选择器，使用 page 替代 */
page {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  background-color: #f1f1f1;
  height: 100%;
}
</style>
