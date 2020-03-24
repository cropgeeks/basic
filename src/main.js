import Vue from 'vue'
import App from './App.vue'
import store from './store'
import router from './router'

// BootstrapVue imports
import BootstrapVue from 'bootstrap-vue'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import { library } from '@fortawesome/fontawesome-svg-core'
import { faAngleDown, faAngleRight } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

library.add(faAngleDown)
library.add(faAngleRight)

Vue.component('font-awesome-icon', FontAwesomeIcon)

// Mixin import
import supplyMixin from './mixins/supply-contract.js'

Vue.mixin(supplyMixin)

Vue.config.productionTip = false

Vue.use(BootstrapVue)

new Vue({
  router,
  store,
  render: h => h(App),
}).$mount('#app')
