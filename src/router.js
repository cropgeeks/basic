import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

const router = new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('./views/Home.vue'),
      meta: {
        title: 'BASIC - Supply Chain',
      }
    },
    {
      path: '/admin',
      name: 'admin',
      component: () => import('./views/Admin.vue'),
      meta: {
        title: 'BASIC - Admin',
      }
    },
    {
      path: '/admin/nursery',
      name: 'admin-nursery',
      component: () => import('./views/AddNursery.vue'),
      meta: {
        title: 'BASIC - Admin | Add Nursery',
      }
    },
    {
      path: '/admin/roles',
      name: 'admin-roles',
      component: () => import('./views/AddAccount.vue'),
      meta: {
        title: 'BASIC - Admin | Add Account',
      }
    },
    {
      path: '/admin/farm',
      name: 'admin-farm',
      component: () => import('./views/AddFarm.vue'),
      meta: {
        title: 'BASIC - Admin | Add Farm',
      }
    },
    {
      path: '/nurseries',
      name: 'nurseries',
      component: () => import('./views/Nurseries.vue'),
      meta: {
        title: 'BASIC - Nurseries',
      }
    },
    {
      path: '/nurseries/:nurseryId',
      name: 'nursery',
      component: () => import('./views/Nursery.vue'),
      meta: {
        title: 'BASIC - Nursery',
      }
    },
    {
      path: '/farms',
      name: 'farms',
      component: () => import('./views/Farms.vue'),
      meta: {
        title: 'BASIC - Farms',
      }
    },
    {
      path: '/farms/:farmId',
      name: 'farm',
      component: () => import('./views/Farm.vue'),
      meta: {
        title: 'BASIC - Farm',
      }
    },
    {
      path: '/plants',
      name: 'plants',
      component: () => import('./views/Plants.vue'),
      meta: {
        title: 'BASIC - Plants',
      }
    },
    {
      path: '/plants/:plantId',
      name: 'plant',
      component: () => import('./views/Plant.vue'),
      meta: {
        title: 'BASIC - Plant',
      }
    },
  ]
})


const DEFAULT_TITLE = 'BASIC - Supply Chain';
router.afterEach((to, from) => {
    document.title = to.meta.title || DEFAULT_TITLE;
})

export default router;